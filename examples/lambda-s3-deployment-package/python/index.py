import logging

logging.basicConfig()
logger = logging.getLogger()
logger.setLevel(logging.INFO)

"""Main entrypoint for the Lambda function. It simply returns "Hello, World".
"""
def handler(event, context):
    logger.info('Received event %s', event)
    return event