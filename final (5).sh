#!/bin/bash
if [ "$(whoami)" != "root" ]
then
    sudo su -s "$0"
    exit
fi
sudo apt-get -y update &&
sudo apt-get -y upgrade &&
sudo apt-get -y install build-essential libpcre3 libpcre3-dev libssl-dev &&
mkdir /working &&
cd /working &&
wget http://nginx.org/download/nginx-1.8.1.tar.gz &&
wget https://github.com/arut/nginx-rtmp-module/archive/master.zip &&
sudo apt-get -y install unzip &&
tar -zxvf nginx-1.8.1.tar.gz &&
unzip master.zip &&
cd nginx-1.8.1 &&
./configure --with-http_ssl_module --with-http_stub_status_module --add-module=../nginx-rtmp-module-master &&
sudo apt-get -y install make &&
make &&
sudo make install &&
sudo wget https://raw.github.com/JasonGiedymin/nginx-init-ubuntu/master/nginx -O /etc/init.d/nginx &&
sudo chmod +x /etc/init.d/nginx &&
sudo update-rc.d nginx defaults &&
sudo service nginx start &&
sudo service nginx stop
sudo mkdir /HLS &&
sudo mkdir /HLS/live &&
sudo mkdir /HLS/live1 &&
sudo mkdir /HLS/live2 &&
sudo mkdir /HLS/live3 &&
sudo mkdir /HLS/live4 &&
sudo mkdir /HLS/live5 &&
#sudo ufw limit ssh &&
sudo ufw allow 80 &&
sudo ufw allow 1935 &&
#sudo ufw enable &&
sudo chmod -R 777 /HLS &&
sudo mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.bak21223
cat <<?>> /usr/local/nginx/conf/nginx.conf
worker_processes  1;
error_log  logs/error.log debug;
events {
worker_connections  1024;
}
rtmp {
server {
listen 1935;
allow play all;

#creates our "live" full-resolution HLS videostream from our incoming encoder stream and tells where to put the HLS video manifest and video fragments
application live{
live on;
hls on;
hls_nested on;
hls_sync 2ms;
hls_path /HLS/live;

}
application live1{
live on;
hls on;
hls_nested on;
hls_sync 2ms;
hls_path /HLS/live1;
hls_keys on;
hls_key_path /HLS/keys;
hls_key_url https://dms.kazastream.com/keys/;
hls_fragments_per_key 2;
}


#allows you to play your recordings of your live streams using a URL like "rtmp://my-ip:1935/vod/filename.flv"

}
}


http {
include       mime.types;
default_type  application/octet-stream;
server {         
listen 443 ssl;         
server_name dms.kazastream.com;          
ssl_certificate /var/sslcerts/dms.kazastream.com.crt;
ssl_certificate_key /var/sslcerts/kazastream.key;          
location /keys {             
 add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
        add_header 'Access-Control-Allow-Headers' 'Range';

        # allow CORS preflight requests
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Headers' 'Range';
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain charset=UTF-8';
            add_header 'Content-Length' 0;
            return 204;
        }
			
root /HLS;         
		}  
location /live {
add_header Cache-Control no-cache;

        # CORS setup
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
        add_header 'Access-Control-Allow-Headers' 'Range';

        # allow CORS preflight requests
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Headers' 'Range';
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain charset=UTF-8';
            add_header 'Content-Length' 0;
            return 204;
        }

        types {
            application/vnd.apple.mpegurl m3u8;
            video/mp2t ts;
        }
alias /HLS/live;
add_header Cache-Control no-cache;
}
location /live1 {
add_header Cache-Control no-cache;

        # CORS setup
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
        add_header 'Access-Control-Allow-Headers' 'Range';

        # allow CORS preflight requests
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Headers' 'Range';
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain charset=UTF-8';
            add_header 'Content-Length' 0;
            return 204;
        }

        types {
            application/vnd.apple.mpegurl m3u8;
            video/mp2t ts;
        }
alias /HLS/live1;
add_header Cache-Control no-cache;
}

   
}
server {
listen 80;
server_name dms.kazastream.com;

#creates the http-location for our full-resolution (desktop) HLS stream - "http://my-ip/live/my-stream-key/index.m3u8"      
location /live {
add_header Cache-Control no-cache;

        # CORS setup
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
        add_header 'Access-Control-Allow-Headers' 'Range';

        # allow CORS preflight requests
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Headers' 'Range';
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain charset=UTF-8';
            add_header 'Content-Length' 0;
            return 204;
        }

        types {
            application/vnd.apple.mpegurl m3u8;
            video/mp2t ts;
        }
alias /HLS/live;
add_header Cache-Control no-cache;
}
location /live1 {
add_header Cache-Control no-cache;

        # CORS setup
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
        add_header 'Access-Control-Allow-Headers' 'Range';

        # allow CORS preflight requests
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Headers' 'Range';
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain charset=UTF-8';
            add_header 'Content-Length' 0;
            return 204;
        }

        types {
            application/vnd.apple.mpegurl m3u8;
            video/mp2t ts;
        }
alias /HLS/live1;
add_header Cache-Control no-cache;
}


 
#allows us to host some webpages which can show our videos: "http://my-ip/my-page.html"     
location / {
root   html;
index  index.html index.htm;
}   
}
}
?
ip=$(wget http://ipinfo.io/ip -qO -)
echo $ip
sudo perl -pi -e "s/IPADD/${ip}/g" /usr/local/nginx/conf/nginx.conf
sudo service nginx restart
sudo apt-get -y  install software-properties-common
sudo add-apt-repository -y  ppa:kirillshkrogalev/ffmpeg-next
sudo apt-get update
sudo apt-get -y install ffmpeg
