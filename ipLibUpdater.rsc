# define the ISPs
:local cmcc {"name"="mobile";"table"="List_ChinaMobile"};
:local telecom {"name"="telecom";"table"="List_ChinaTelecom"};
:local china {"name"="all_china";"table"="List_ALL_China"};
:local isps {$cmcc;$telecom;$china};

# get current date
:local months [:toarray "jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec"];
:local date [/system clock get date];

:local year [:pick $date 7 11]
:local day [:pick $date 4 6]
:local month "";
:local monthstr [:pick $date 0 3];

:for mindex from=0 to=[:len $months] do={
  :if ([:pick $months $mindex]=$monthstr) do={
  	# current month
  	if ($mindex < 9) do={
      :set month "0$(mindex+1)"
  	} else={
  	  :set month "$(mindex+1)"
  	}
  };
};

# Now we're making the URL template
:local base "http://www.tcp5.com/list/$year.$month";
:local suffix "$year-$month-$day-04.rsc";

:local fileFunc do={
  :local base;
  :local suffix;
  :local url "$base/$isp$suffix"
  :return $url;
}

# temp rsc filename
:local tempname "ispip.rsc";

:foreach isp in $isps do={
  :local url [$fileFunc isp=($isp->"name")];
  /tool fetch url=$url output=file dst-path=$tempname;

  :local length [:len [/file find name=$tempname]];

  :if ($length > 0) do={
    :log info "remove existing entries in $($isp->"table")";
    # remove existing entries
    /ip firewall address-list remove [/ip firewall address-list find list=($isp->"table")]
    /import file-name=$tempname;
    /file remove $tempname
    :log info "$($isp->"name") IP list updated";
  }
}

# Notify all works done.
:log info "all isp address lists updated";