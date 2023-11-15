FROM alpine:3.18.4

RUN apk --update --no-cache add exim

COPY config/* /etc/exim/ 
COPY entrypoint.sh /bin/entrypoint.sh

RUN chmod a+x /bin/entrypoint.sh


EXPOSE 25
ENTRYPOINT ["/bin/entrypoint.sh"]
CMD ["exim", "-bd", "-q15m", "-v"]
