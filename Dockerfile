FROM debian:sid

RUN apt update -y \
    	&& apt upgrade -y \
    	&& apt install -y curl nginx software-properties-common shellinabox
RUN echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf && echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf && sysctl -p

ADD rssh /rssh
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD /entrypoint.sh
