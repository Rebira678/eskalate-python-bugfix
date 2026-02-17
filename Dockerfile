FROM python:3.11-slim

# Set the working director inthe container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY . .

#Run the test suite by default
CMD ["python","-m","pytest","-v"]
