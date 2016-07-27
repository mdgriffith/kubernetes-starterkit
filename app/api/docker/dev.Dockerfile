FROM python-dependencies:2.7

ENV DEBUG="False"
ENV DB_NAME=postgres
ENV DB_SERVICE=postgres
ENV DB_PORT=5432

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY requirements.txt /usr/src/app/
RUN pip install --no-cache-dir -r requirements.txt

COPY . /usr/src/app

CMD /usr/local/bin/gunicorn -w 2 -b :8000 manage:app --reload --access-logfile '-' --access-logformat '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s"'
EXPOSE 8000
