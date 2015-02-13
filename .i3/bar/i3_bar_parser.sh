#!/bin/bash
#
# Input parser for i3 bar

. $(dirname $0)/i3_bar_config

irc_n_high=0
mpc="%{F${color_sec_b3}}${sep_left}%{F${color_icon} B${color_sec_b3}} %{T2}${icon_music}%{F${color_fore} T-} U2 %{F${color_icon}}${sep_l_left} %{F${color_fore} T-} Crumbs from Your Table"

while read -r line ; do
  case $line in
    SYS*)
      # conky=, 0 = wday, 1 = mday, 2 = month, 3 = time, 4 = cpu, 5 = mem, 6 = disk /, 7 = disk /home, 8-9 = up/down wlan, 10-11 = up/down eth, 12-13=speed
      sys_arr=(${line#???})
      # date
      date="%{F${color_sec_b1}}${sep_left}%{F${color_icon} B${color_sec_b1}} %{T2}${icon_clock}%{F- T-} ${sys_arr[0]} ${sys_arr[1]} ${sys_arr[2]}"
      # time
      time="%{F${color_head}}${sep_left}%{F${color_back} B${color_head}} ${sys_arr[3]} %{F- B-}"
      # cpu
      if [ ${sys_arr[4]} -gt ${cpu_alert} ]; then
        cpu_cback=${color_cpu}; cpu_cicon=${color_back}; cpu_cfore=${color_back};
      else
        cpu_cback=${color_sec_b2}; cpu_cicon=${color_icon}; cpu_cfore=${color_fore};
      fi
      cpu="%{F${cpu_cback}}${sep_left}%{F${cpu_cicon} B${cpu_cback}} %{T2}${icon_cpu}%{F${cpu_cfore} T-} ${sys_arr[4]}%%"
      # mem
      mem="%{F${cpu_cicon}}${sep_l_left} %{T2}${icon_mem}%{F${cpu_cfore} T-} ${sys_arr[5]}"
      # disk /
      diskr="%{F${color_sec_b1}}${sep_left}%{F${color_icon} B${color_sec_b1}} %{T2}${icon_hd}%{F- T-} ${sys_arr[6]}%%"
      # disk home
      diskh="%{F${color_icon}}${sep_l_left} %{T2}${icon_home}%{F- T-} ${sys_arr[7]}%%"
      # wlan
      if [ "${sys_arr[8]}" == "down" ]; then
        wland_v="×"; wlanu_v="×";
        wlan_cback=${color_sec_b2}; wlan_cicon=${color_disable}; wlan_cfore=${color_disable};
      else
        wland_v=${sys_arr[8]}K; wlanu_v=${sys_arr[9]}K;
        if [ ${wland_v:0:-3} -gt ${net_alert} ] || [ ${wlanu_v:0:-3} -gt ${net_alert} ]; then
          wlan_cback=${color_net}; wlan_cicon=${color_back}; wlan_cfore=${color_back};
        else
          wlan_cback=${color_sec_b2}; wlan_cicon=${color_icon}; wlan_cfore=${color_fore};
        fi
      fi
      wland="%{F${wlan_cback}}${sep_left}%{F${wlan_cicon} B${wlan_cback}} %{T2}${icon_dl}%{F${wlan_cfore} T-} ${wland_v}"
      wlanu="%{F${wlan_cicon}}${sep_l_left} %{T2}${icon_ul}%{F${wlan_cfore} T-} ${wlanu_v}"
      # eth
      if [ "${sys_arr[10]}" == "down" ]; then
        ethd_v="×"; ethu_v="×";
        eth_cback=${color_sec_b1}; eth_cicon=${color_disable}; eth_cfore=${color_disable};
      else
        ethd_v=${sys_arr[10]}K; ethu_v=${sys_arr[11]}K;
        if [ ${ethd_v:0:-3} -gt ${net_alert} ] || [ ${ethu_v:0:-3} -gt ${net_alert} ]; then
          eth_cback=${color_net}; eth_cicon=${color_back}; eth_cfore=${color_back};
        else
          eth_cback=${color_sec_b1}; eth_cicon=${color_icon}; eth_cfore=${color_fore};
        fi
      fi
      ethd="%{F${eth_cback}}${sep_left}%{F${eth_cicon} B${eth_cback}} %{T2}${icon_dl}%{F${eth_cfore} T-} ${ethd_v}"
      ethu="%{F${eth_cicon}}${sep_l_left} %{T2}${icon_ul}%{F${eth_cfore} T-} ${ethu_v}"
      ;;
    VOL*)
      # Volume
      vol="%{F${color_sec_b2}}${sep_left}%{F${color_icon} B${color_sec_b2}} %{T2}${icon_vol}%{F- T-} ${line#???}%%"
      ;;
    GMA*)
      # Gmail
      n_mail="${line#???}"
      if [ "${n_mail}" != "0" ]; then
        mail_cback=${color_mail}; mail_cicon=${color_back}; mail_cfore=${color_back}
      else
        mail_cback=${color_sec_b1}; mail_cicon=${color_icon}; mail_cfore=${color_fore}
      fi
      gmail="%{F${mail_cback}}${sep_left}%{F${mail_cicon} B${mail_cback}} %{T2}${icon_mail}%{F${mail_cfore} T-} ${n_mail}"
      ;;
    IRC*)
      # IRC highlight (script irc_warn)
      if [ "${line#???}" != "0" ]; then
        ((irc_n_high++)); irc_high="${line#???}";
        irc_cback=${color_chat}; irc_cicon=${color_back}; irc_cfore=${color_back}
      else
        irc_n_high=0; [ -z "${irc_high}" ] && irc_high="none";
        irc_cback=${color_sec_b2}; irc_cicon=${color_icon}; irc_cfore=${color_fore}
      fi
      irc="%{F${irc_cback}}${sep_left}%{F${irc_cicon} B${irc_cback}} %{T2}${icon_chat}%{F${irc_cfore} T-} ${irc_n_high} %{F${irc_cicon}}${sep_l_left} %{T2}${icon_contact}%{F${irc_cfore} T-} ${irc_high}"
      ;;
    WIN*)
      # window title
      win=$(xprop -id ${line#???} | awk '/_NET_WM_NAME/{$1=$2="";print}' | cut -d'"' -f2)
      title="%{F${color_back} B${color_head}} 1 %{R}${sep_right} 2 %{R}${sep_right} 3 %{T2}${icon_prog}%{R}${sep_right}%{F- B- T-} ${win}"
      ;;
  esac

  # And finally, output
  printf "%s\n" "%{l}${title} %{r}${mpc}${stab}${irc}${stab}${gmail}${stab}${cpu}${stab}${mem}${stab}${diskr}${stab}${diskh}${stab}${wland}${stab}${wlanu}${stab}${ethd}${stab}${ethu}${stab}${vol}${stab}${date}${stab}${time}"
done