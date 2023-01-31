#!/bin/bash


# get params
echo "name_cam:"
read name_cam

echo "tg_token:"
read tg_token

echo "tg_id:"
read tg_id

echo "netcam_url:"
read netcam_url

echo "netcam_highres:"
read netcam_highres

echo ""
echo name_cam:$name_cam
echo tg_token:$tg_token
echo tg_id:$tg_id
echo netcam_url:$netcam_url
echo netcam_highres:$netcam_highres

echo ""
echo "Exit if data is incorrect (ctrl + c). Install starts in 15 seconds"
sleep 10
echo "5 seconds"
sleep 5
echo "starting..."


# update
apt update && apt upgrade

apt install imagemagick libjson-c-dev

# build motion
apt install autoconf automake autopoint build-essential pkgconf libtool libzip-dev libjpeg-dev git libavformat-dev libavcodec-dev libavutil-dev libswscale-dev libavdevice-dev libwebp-dev gettext libmicrohttpd-dev

cd ~

git clone https://github.com/Motion-Project/motion.git

cd motion

autoreconf -fiv

./configure

make

make install

cd ~

rm -rf ./motion

echo "ramdisk /mnt/ramdisk tmpfs rw,size=256M 0 0" >> /etc/fstab


# install ivc-kolpak
cp -r /camTg-notification/ivc-kolpak/ /etc/ivc-kolpak

# copy bins
chmod 700 /etc/ivc-kolpak/tgbot/
ln -s /etc/ivc-kolpak/tgbot/* /usr/bin/

chmod 700 /etc/ivc-kolpak/motion/
ln -s /etc/ivc-kolpak/motion/motion.conf /usr/bin/

ln -s /etc/ivc-kolpak/bin/libtelebot.so.0.4.5 /lib/

chmod 700 /etc/ivc-kolpak/bin/estgb
ln -s /etc/ivc-kolpak/bin/estgb /usr/bin/estgb

chmod 700 /bin/{stats.sh,tgbot.sh,tgbotaudio.sh,tgbotdoc.sh,tgbotpic.sh,tgbottext.sh,tgbotvideo.sh}

chmod 700 /usr/bin/estgb

# copy to configs
mkdir /etc/ivc-kolpak/channels/$name_cam
echo $tg_token > /etc/ivc-kolpak/channels/$name_cam/.token
echo $tg_id > /etc/ivc-kolpak/channels/$name_cam/.userid

# да, я не нашёл ничего лучше, чем просто скопировать рабочий конфиг. sed-ом проходиться по нему страшно.
cat > /etc/ivc-kolpak/channels/$name_cam.conf << EOF
###########################################################
# Configuration options specific to camera 1
############################################################

############################################################
# IVC KOLPAK PROJECT
# (c) 2018-2025 Flangeneer
# Any questions ask in telegram group: @ivckolpak
# Saint-Petersburg, 2018-2025
############################################################

# Target dir for files
target_dir /mnt/ramdisk

# Camera config
camera_name camera_main
camera_id 101
#videodevice /dev/video0
#v4l2_palette 8
#netcam_use_tcp off
netcam_url $netcam_url
netcam_highres $netcam_highres

# Image in pixels.
width 800
height 448
framerate 25

# Text to be overlayed in the lower left corner of images
text_left $name_cam - MAIN 
text_right %Y-%m-%d\n%T-%q

output_pictures best
picture_filename CAM01_%Y%m%d%H%M%S-%q
locate_motion_mode preview
locate_motion_style redbox
minimum_motion_frames 10
event_gap 5
pre_capture 2
post_capture 2
threshold 250
lightswitch_percent 70
lightswitch_frames 50
noise_tune on
#mask_file /etc/ivc-kolpak/motion/ivanova41-1.pgm

movie_output on
movie_passthrough on
movie_duplicate_frames off
movie_filename %t-%v-%Y%m%d-%H%M%S
movie_max_time 90

# The port number for the live stream.
stream_port 49001
stream_localhost off
stream_maxrate 25

on_picture_save tgbotpic.sh "$name_cam" "%f"
on_movie_end tgbotvideo.sh "$name_cam" "%f" "\xF0\x9F\x95\x93 %H:%M:%S \xF0\x9F\x93\x85 %d.%m.%Y\n\xF0\x9F\x8E\x9E"
#on_picture_save tgbot_mediapic.sh
#on_event_end tgbot_mediapic.sh
on_camera_lost tgbottext.sh "$name_cam" "Camera connection lost"
on_camera_found tgbottext.sh "$name_cam" "Camera connetion established"
EOF

chmod 700 /etc/ivc-kolpak/channels/

ln -s /etc/ivc-kolpak/channels/$name_cam.conf /usr/bin/