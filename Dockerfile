FROM alpine:latest

# Install Python, pip, and common build dependencies for Python libraries
RUN apk add --no-cache --update python3 py3-pip bash gcc musl-dev libffi-dev

# Copy application dependencies
COPY ./webapp/requirements.txt /tmp/requirements.txt

# Install dependencies
RUN pip3 install --no-cache-dir -q -r /tmp/requirements.txt

# Copy application code
COPY ./webapp /opt/webapp/
WORKDIR /opt/webapp

# Add and switch to a non-root user
RUN adduser -D myuser
USER myuser

# Set the default command to run the application
CMD gunicorn --bind 0.0.0.0:$PORT wsgi
