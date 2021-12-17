FROM postgres:12.4
RUN apt-get update
RUN apt-get install -y git golang make curl 
RUN git clone https://github.com/spiffe/spiffe-helper
WORKDIR /spiffe-helper
RUN make build
COPY helper.conf /spiffe-helper
COPY create_user.sql /spiffe-helper
