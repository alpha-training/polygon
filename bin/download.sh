source .env

nohup taskset -c 2,3 /opt/q/l64/q q/boot.q -script download -p 1234 </dev/null >>log/download.log 2>&1 &
