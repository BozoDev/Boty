import asyncio, io, logging, os, subprocess, re, time
import plugins


logger = logging.getLogger(__name__)


_cocext = { "running": False }


def _initialise(bot):
    plugins.register_user_command(["screen", "coc"])
    plugins.register_admin_command(["setlog", "clearlog"])


@asyncio.coroutine
def _open_file(name):
    logger.debug("opening file: {}".format(name))
    return open(name, 'rb')


@asyncio.coroutine
def _screen( filename):
    logger.info("screen as {}".format(filename))

    loop = asyncio.get_event_loop()

    # read the file into a byte array
    file_resource = yield from _open_file(filename)
    file_data = yield from loop.run_in_executor(None, file_resource.read)
    image_data = yield from loop.run_in_executor(None, io.BytesIO, file_data)
    yield from loop.run_in_executor(None, os.remove, filename)

    return image_data


def setlog(bot, event, *args):
    """set log from CoCerBot-pipe for current converation
    use /bot clearlog to clear it
    """
    logpipe = bot.conversation_memory_get(event.conv_id, 'logpipe')
    if logpipe is None:
        bot.conversation_memory_set(event.conv_id, 'logpipe', ''.join(args))
        html = "<i><b>{}</b> updated logpipe URL".format(event.user.full_name)
        yield from bot.coro_send_message(event.conv, html)

    else:
        html = "<i><b>{}</b> URL already exists for this conversation!<br /><br />".format(event.user.full_name)
        html += "<i>Clear it first with /bot clearlog before setting a new one."
        yield from bot.coro_send_message(event.conv, html)


def clearlog(bot, event, *args):
    """clear log-pipe for current converation
    """
    logpipe = bot.conversation_memory_get(event.conv_id, 'logpipe')
    if logpipe is None:
        html = "<i><b>{}</b> nothing to clear for this conversation".format(event.user.full_name)
        yield from bot.coro_send_message(event.conv, html)

    else:
        bot.conversation_memory_set(event.conv_id, 'logpipe', None)
        html = "<i><b>{}</b> Log cleared for this conversation!<br />".format(event.user.full_name)
        yield from bot.coro_send_message(event.conv, html)


def screen(bot, event, *args):
    """get a screenshot of current CoCerBot
    """
    if _cocext["running"]:
        yield from bot.coro_send_message(event.conv_id, "<i>processing another request, try again shortly</i>")
        return

    if args:
        img = args[0]
    else:
        img = bot.conversation_memory_get(event.conv_id, 'img')

    if img is None:
        img = '/tmp/CoCNow.png'

    else:
        _cocext["running"] = True
        
        if not re.match(r'^/tmp/', img):
            img = '/tmp/' + img
        filename = event.conv_id + "." + str(time.time()) +".png"
        filepath = os.path.join(os.path.dirname(os.path.realpath(__file__)), filename)
        logger.debug("temporary screenshot file: {}".format(filepath))

        params = ['/usr/bin/convert', '-colorspace', 'gray', img, filename ]
        try:
            subprocess.check_call(params)
        except subprocess.CalledProcessError as e:
            yield from bot.coro_send_message(event.conv, "<i>Imagick convert failed</i>".format(e))
            _cocext["running"] = False
            return
        
        try:
            loop = asyncio.get_event_loop()
            image_data = yield from _screen( filename)

        except Exception as e:
            yield from bot.coro_send_message(event.conv_id, "<i>error getting screenshot</i>")
            logger.exception("screencap failed".format(url))
            _cocext["running"] = False
            return
            
        try:
            image_id = yield from bot._client.upload_image(image_data, filename=filename)
            yield from bot._client.sendchatmessage(event.conv.id_, None, image_id=image_id)

        except Exception as e:
            yield from bot.coro_send_message(event.conv_id, "<i>error uploading screenshot</i>")
            logger.exception("upload failed".format(filename))
            _cocext["running"] = False

        finally:
            _cocext["running"] = False


def coc(bot, event, *args):
    """Various actions for the bot to perform
    """
    if _cocext["running"]:
        yield from bot.coro_send_message(event.conv_id, "<i>processing another request, try again shortly</i>")
        return

    cmd = args[0]
    while True:
      if cmd == "init":
          params = ['~/CoCerBot/HangoutsBot/hangoutsbot/hangupsbot/plugins/CoCerBot/init']
          try:
              subprocess.check_call(params)

          except subprocess.CalledProcessError as e:
              yield from bot.coro_send_message(event.conv, "<i>Error running init command</i>".format(e))

          break

      if cmd == "grab":
          params = ['~/CoCerBot/HangoutsBot/hangoutsbot/hangupsbot/plugins/CoCerBot/grab']
          try:
              subprocess.check_call(params)

          except subprocess.CalledProcessError as e:
              yield from bot.coro_send_message(event.conv, "<i>Error running grab command</i>".format(e))

          break

      if cmd == "raw":
          params = ['~/CoCerBot/HangoutsBot/hangoutsbot/hangupsbot/plugins/CoCerBot/raw', args[1], args[2], args[3], args[4], args[5]]
          try:
              subprocess.check_call(params)

          except subprocess.CalledProcessError as e:
              yield from bot.coro_send_message(event.conv, "<i>Error running raw command</i>".format(e))

          break

      logger.debug("No command entered")
      yield from bot.coro_send_message(event.conv_id, "<i>Currently supported actions:</i><br>")
      yield from bot.coro_send_message(event.conv_id, "<b>init</b>      Start up the bot - get in, collect Resis<br>")
      break


