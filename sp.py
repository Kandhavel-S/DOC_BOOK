import os
import pandas as pd
from flask import Flask, request, jsonify
from flask_cors import CORS
import logging
import traceback
import google.generativeai as genai
from sklearn.preprocessing import LabelEncoder
from sklearn.tree import DecisionTreeClassifier

# Set up logging
logging.basicConfig(level=logging.DEBUG)

# Initialize the Flask app
app = Flask(__name__)
CORS(app)

# Ensure the API key is set correctly
api_key = "AIzaSyDFiEwUSBtEuIqfMVeVoTjWUIP4NGMyYFA"  # Replace with your actual API key
if not api_key:
    raise ValueError("No API_KEY found. Please set the `API_KEY` environment variable.")

genai.configure(api_key=api_key)

# Create the model for Gemini
generation_config = {
    "temperature": 1.05,
    "top_p": 0.95,
    "top_k": 64,
    "max_output_tokens": 8192,
}

try:
    gemini_model = genai.GenerativeModel(
        model_name="gemini-1.5-pro",
        generation_config=generation_config,
    )
except Exception as e:
    logging.error(f"Error initializing Gemini model: {str(e)}")
    raise

history = []

# Load dataset and preprocess it for the decision tree model
df = pd.read_csv(r'C:\Users\dhars\Downloads\Flutter Train\healthcare_app\doctor_schedules (1).csv')
df['intime'] = pd.to_datetime(df['intime'], format='%H:%M:%S').dt.hour
df['outtime'] = pd.to_datetime(df['outtime'], format='%H:%M:%S').dt.hour

# Encode categorical variables
le_place = LabelEncoder()
df['place'] = le_place.fit_transform(df['place'])

le_hospital_name = LabelEncoder()
df['hospital_name'] = le_hospital_name.fit_transform(df['hospital_name'])

le_doctor_name = LabelEncoder()
df['doctor_name'] = le_doctor_name.fit_transform(df['doctor_name'])

le_specialization = LabelEncoder()
df['specialization'] = le_specialization.fit_transform(df['specialization'])

le_qualification = LabelEncoder()
df['qualification'] = le_qualification.fit_transform(df['qualification'])

# Create a target variable
df['target'] = df.apply(lambda row: f"{row['hospital_name']}_{row['doctor_name']}_{row['qualification']}", axis=1)
le_target = LabelEncoder()
df['target'] = le_target.fit_transform(df['target'])

# Split data into features and target
X = df[['place', 'specialization', 'intime', 'outtime']]
y = df['target']

# Train the decision tree model
dt_model = DecisionTreeClassifier()
dt_model.fit(X, y)

# Function to extract hospitals based on location
def extract_hospitals_by_location(location):
    logging.debug(f"Extracting hospitals for location: {location}")
    # Convert location to the encoded format
    location_encoded = le_place.transform([location])[0]

    # Filter data by the specified location
    filtered_df = df[df['place'] == location_encoded]

    # Extract unique hospital names
    hospitals_encoded = filtered_df['hospital_name'].unique()
    hospitals = le_hospital_name.inverse_transform(hospitals_encoded)

    logging.debug(f"Hospitals found: {hospitals}")

    return hospitals.tolist()

@app.route('/hospitals', methods=['POST'])
def get_hospitals():
    try:
        data = request.get_json()
        location = data.get('location')

        if not location:
            return jsonify({"error": "No location provided"}), 400

        # Extract hospitals based on location
        hospitals = extract_hospitals_by_location(location)

        if hospitals:
            return jsonify({"hospitals": hospitals}), 200
        else:
            return jsonify({"message": "No hospitals found."}), 404
    except Exception as e:
        logging.error(f"An error occurred: {str(e)}")
        logging.error(traceback.format_exc())
        return jsonify({"error": str(e), "traceback": traceback.format_exc()}), 500

@app.route('/query', methods=['POST'])
def query():
    try:
        data = request.get_json()
        logging.info(f"Received data: {data}")
        
        user_input = data.get('query')
        
        if not user_input:
            return jsonify({"error": "No query provided"}), 400

        logging.info(f"Processed query: {user_input}")

        # Start the chat session
        chat_session = gemini_model.start_chat(history=history)

        # Send the user input to the chat session
        response = chat_session.send_message(user_input)

        # Extract the model's response text
        model_response = response.text

        # Append the conversation history
        history.append({"role": "user", "parts": [user_input]})
        history.append({"role": "model", "parts": [model_response]})

        logging.info(f"Generated response: {model_response}")

        return jsonify({"response": model_response})
    except Exception as e:
        logging.error(f"An error occurred: {str(e)}")
        logging.error(traceback.format_exc())
        return jsonify({"error": str(e), "traceback": traceback.format_exc()}), 500

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()

    # Extract inputs from the request
    place = data['place']
    specialization = data['specialization']
    time = data['time']

    # Encode the inputs
    place_encoded = le_place.transform([place])[0]
    specialization_encoded = le_specialization.transform([specialization])[0]
    time_parsed = pd.to_datetime(time, format='%H:%M:%S').hour

    # Create input for the model
    input_data = pd.DataFrame([[place_encoded, specialization_encoded, time_parsed, time_parsed]],
                              columns=['place', 'specialization', 'intime', 'outtime'])

    # Predict using the model
    predictions = dt_model.predict(input_data)
    results = []

    # Decode and prepare the results
    for prediction in predictions:
        decoded_target = le_target.inverse_transform([prediction])[0]
        hospital_name_encoded, doctor_name_encoded, qualification_encoded = map(int, decoded_target.split('_'))
        
        result = {
            'place': place,
            'hospital_name': le_hospital_name.inverse_transform([hospital_name_encoded])[0],
            'doctor_name': le_doctor_name.inverse_transform([doctor_name_encoded])[0],
            'specialization': specialization,
            'qualification': le_qualification.inverse_transform([qualification_encoded])[0]
        }
        results.append(result)

    return jsonify(results)

if __name__ == '__main__':
    app.run(debug=True, host='192.168.137.1', port=5000)
