import mailbox
import csv
import os
import sys
from datetime import datetime, timezone
from dateutil import parser

def progressBar(iterable, prefix = '', suffix = '', decimals = 1, length = 100, fill = '█', printEnd = '\r'):
    '''
    Call in a loop to create terminal progress bar
    @params:
        iterable    - Required  : iterable object (Iterable)
        prefix      - Optional  : prefix string (Str)
        suffix      - Optional  : suffix string (Str)
        decimals    - Optional  : positive number of decimals in percent complete (Int)
        length      - Optional  : character length of bar (Int)
        fill        - Optional  : bar fill character (Str)
        printEnd    - Optional  : end character (e.g. '\r', '\r\n') (Str)
    '''
    total = len(iterable)
    # Progress Bar Printing Function
    def printProgressBar (iteration):
        percent = ('{0:.' + str(decimals) + 'f}').format(100 * (iteration / float(total)))
        filledLength = int(length * iteration // total)
        bar = fill * filledLength + '-' * (length - filledLength)
        print(f'\r{prefix} |{bar}| {percent}% {suffix}', end = printEnd)
    # Initial Call
    printProgressBar(0)
    # Update Progress Bar
    for i, item in enumerate(iterable):
        yield item
        printProgressBar(i + 1)
    # Print New Line on Complete
    print()

def getcharsets(msg):
    charsets = set({})
    for c in msg.get_charsets():
        if c is not None:
            charsets.update([c])
    return charsets

def getBody(msg):
    while msg.is_multipart():
        msg=msg.get_payload()[0]
    t=msg.get_payload(decode=True)
    for charset in getcharsets(msg):
        t=t.decode(charset)
    return t

mbox_file = input('Enter filename: ')
if mbox_file[-5:] != '.mbox':
    print('Please provide a MBOX file!')
    sys.exit()

csv_file = mbox_file.replace('.mbox', '.csv')
mbox = mailbox.mbox(mbox_file)
if os.path.isfile(csv_file):
    os.remove(csv_file)

with open(csv_file, 'w+', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['FromAddress', 'ToAddress', 'CcAddress', 'Subject', 'MessageDate', 'MessageIdentifier', 'HtmlBody'])
    counter = 0
    errors = []
    print('Emails to process: '+str(len(mbox)))
    for message in progressBar(mbox, prefix = 'Progress:', suffix = 'Complete', length = 50):
        # Extract the relevant fields from the message
        if not (message['From'] and message['To']):
            continue
        subject = message['Subject']
        from_addr = message['From']
        try:
            if '<' in from_addr:
                from_addr = from_addr.split('<')[1].split('>')[0].strip()
        except:
            errors.append('From Header error: '+subject)
            continue
        to_addresses = []
        try:
            for to_addr in message['To'].split(','):
                if '<' in to_addr:
                    to_addresses.append(to_addr.split('<')[1].split('>')[0].strip())
                else:
                    to_addresses.append(to_addr.strip())
        except:
            errors.append('To Header error: '+from_addr+' --> '+subject)
            continue
        cc_addresses = []
        if message['CC']:
            for cc_addr in message['CC'].split(','):
                if '<' in to_addr:
                    cc_addresses.append(to_addr.split('<')[1].split('>')[0].strip())
                else:
                    cc_addresses.append(to_addr.strip())
        try:
            msg_date_object = parser.parse(message['Date']).astimezone(timezone.utc)
        except:
            errors.append('Date parsing error: '+from_addr+' --> '+subject)
            continue
        message_date = msg_date_object.strftime('%Y-%m-%dT%H:%M:%S')+'.000+0000'
        message_id = message['Message-ID']
        try:
            body = getBody(message)
            body = body[:10000]
        except UnicodeDecodeError:
            errors.append('Decoding error: '+from_addr+' --> '+subject);
        else:
            # Write the fields to the CSV file
            writer.writerow([from_addr, ','.join(to_addresses), ','.join(cc_addresses), subject, message_date, message_id, body])
            counter = counter+1
    print('Total emails processed: '+str(counter))
    if len(errors) > 0:
        print('Total errors: 0')
        for error in errors:
            print(error)
