# A simple test harness that can be used to run and test the lambda function locally. It creates a mock event object
# for the function based on user input, decodes the base64-encoded image data returned by the lambda function, and
# writes it to disk.

import logging
import argparse
import json
from index import handler

logging.basicConfig()
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def run_handler_locally(event_str):
    event = json.loads(event_str)

    logger.info('Running lambda function locally with event object:', event)
    result = handler(event, None)

    logging.info('Got result:')
    logging.info(result)

parser = argparse.ArgumentParser(description='Run the lambda function locally and print the result to stdout')

parser.add_argument('--event', help='The JSON event to send to the lambda function', required=True)

args = parser.parse_args()

run_handler_locally(args.event)
