import logging

logging.basicConfig()
logger = logging.getLogger()
logger.setLevel(logging.INFO)

"""Main entrypoint for the Lambda function. It raises an exception to send to DLQ".
"""
def handler(event, context):
    logger.info('Received event %s', event)

    logger.info('Intentionally raising exception to test DLQ')

    raise Exception('Exception: sending to DLQ')

    return event
