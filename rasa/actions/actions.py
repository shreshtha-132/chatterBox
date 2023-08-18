import requests
from typing import Any, Text, Dict, List
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher

class ActionGetWeather(Action):
    def name(self) -> Text:
        return "action_get_weather"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        city = "New Delhi"  # Fixed city value
        api_key = "bf37ed037ee6f380172b8531dab4154f"  # Replace with your Weatherstack API key
        url = f"http://api.weatherstack.com/current?access_key={api_key}&query={city}"
        response = requests.get(url).json()

        if "current" in response:
            temperature = response["current"]["temperature"]
            weather_description = response["current"]["weather_descriptions"][0]
            message = f"The weather in {city} is {weather_description} with a temperature of {temperature}°C."
        else:
            message = "Sorry, I couldn't retrieve the weather information."

        dispatcher.utter_message(text=message)

        return []
