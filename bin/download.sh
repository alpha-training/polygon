source .env

nohup taskset -c 2,3 /opt/q/l64/q q/boot.q -script polygon_download -p 1234 </dev/null >>log/download.log 2>&1 &
