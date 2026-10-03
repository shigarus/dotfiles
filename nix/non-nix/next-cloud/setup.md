sudo chmod -R 750 /home/shigarus/nc
sudo chown -R 33:0 /home/shigarus/ncdata
// should go to nix config, but here for the moment
sudo tailscale funnel 4500  # add -bg for not holding terminal
sudo docker-compose up

open AoI interface on https://127.0.0.1:8080 (certs are invalid, that is ok)
And paste domain name from tailscale
