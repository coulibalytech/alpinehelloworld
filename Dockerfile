FROM alpine:latest

# Copy application dependencies
COPY ./webapp/requirements.txt /tmp/requirements.txt

# Install Python, pip, and common build dependencies for Python libraries
RUN apk add --no-cache python3 py3-pip && python3 -m ensurepip && pip3 install --upgrade pip

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
