import rHLDS, yaml, re, time, os

# Default port 27015
srv = rHLDS.Console(host=os.environ['RCON_HOST'], port=os.environ['RCON_PORT'], password=os.environ['RCON_PASSWORD'])

# Connect to server
srv.connect()

file1 = open("data.txt", "a+")

while True:
        data = srv.execute("stats")
        fps = re.search('(\d+.?\d*)(\d+.?\d*\s*)(\d+.?\d*\s*)(\d+.?\d*\s*)(\d+.?\d*\s*)(\d+.?\d*\s*)(\d+.?\d*\s*)', data).group(7)
        if fps:
                file1.write("%d,%s\n" % (time.time(), fps))
        time.sleep(10)

file1.close()
srv.disconnect()

