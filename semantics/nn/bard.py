from flask import Flask, request, jsonify
from bardapi import BardCookies
import os

app = Flask(__name__)

@app.route('/nn/process', methods=['POST'])
def process_data():
    # Get the 'data' parameter from the request's JSON data
    request_data = request.get_json()

    
    cookie_dict = {
        '__Secure-1PSID': os.getenv('11PSID'),
        '__Secure-1PSIDTS': os.getenv('11PSIDTS'),
        '__Secure-1PSIDCC': os.getenv('1PSIDCC'),
        '__Secure-1PAPISID': os.getenv('1PAPISID')
    }

    # Check if 'data' is present in the request
    if 'data' in request_data and isinstance(request_data['data'], dict):
        data = request_data['data']

        bard = BardCookies(cookie_dict=cookie_dict)
        query_string = f'''Can you give me the name of the supplier that created data in {data["file_ending"]} format,
    {data["language"]} language, and charset is {data["charset"]} and
    header row contains these data: {data["headers"]}\n
    As a response, please give me ONLY (one word!) the name of the supplier'''


        response = bard.get_answer(query_string)['content']
        print(f'Bard response is: {response}')

        return response, 200

    # If 'data' or any required key is missing, return an error
    return 'Error in Bard communication', 400

if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0")

