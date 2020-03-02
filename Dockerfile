FROM frolvlad/alpine-miniconda3:latest
LABEL maintainer="w.baars@wimbo.nl"

# Required system packages and cleanup
RUN apk update \
    && apk add tesseract-ocr curl wget tesseract-ocr-dev

# Custom user to so we don't run under root
RUN adduser --home /home/apiuser --disabled-password --shell /bin/sh apiuser

# Install the conda packages
RUN conda config --add channels conda-forge
RUN conda install --yes \
    fastapi=0.43.0 \
    uvicorn=0.9.1

# Install the pip packages
RUN pip install \
    requests \
    requests[socks] \
    requests[security] \
    fake_headers \
    tesseract \
    pytesseract \
    Pillow \
    opencv-python-headless

# Switch to apiuser
USER apiuser
WORKDIR /home/apiuser
RUN mkdir /home/apiuser/app
RUN mkdir /home/apiuser/app/cache

# Copy the python files to the image
COPY ./app/api.py /home/apiuser/app/api.py
COPY ./app/gas_prices.py /home/apiuser/app/gas_prices.py
WORKDIR /home/apiuser/app

# Expose 5035 port for API
EXPOSE 5035

# Run fastapi with the app (api.py)
CMD ["/bin/sh", "-c", "uvicorn --proxy-headers api:app --host=0.0.0.0 --port=5035"]
