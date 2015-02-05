FROM training/showoff:921817e

COPY /slides/ /slides/
WORKDIR /slides

CMD [ "showoff", "serve" ]

EXPOSE 9090
