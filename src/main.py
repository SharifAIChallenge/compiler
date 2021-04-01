from event import Event_Status
from compiler import compile
import kafka_cli as kcli
import json
import log
import logging


log.init()
logger=logging.getLogger("main")

for message in kcli.get_consumer():
    try:
        code = json.loads(message.value.decode("utf-8"))
        log.new_token_logger(code['code_id'])
        logger.info(f"===================[{code}]===================")
        logger.info("successfully accuried new record")
        event = compile(code['code_id'], code['language'])
        logger.info (f"event retrived with status code [{Event_Status(event.status_code).name}]")
        logger.info(f"resulting event is: {event.title}")
        kcli.push_event(event.__dict__)
    except Exception as e:
        logger.exception()
    finally:
        logging.info(f"===================[{'='*32}]===================")
        logger.removeHandler(code['code_id'])    
        kcli.get_consumer().commit()