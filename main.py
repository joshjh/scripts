# the script should be executed by a systemd unit.  It will call COWSAY and fortune, log into the throwaway email addy
# and fire the results to my work email

import smtplib
import subprocess
import keyring

GBL_WORKEMAIL = "josh@webhost.virbr0"
GBL_SMTP_ADDRESS = "smtp"
GBL_SMTP_PORT = 25
GBL_SMTP_USER_NAME = "josh"

def get_passwd() -> str:
    # password needs to be loaded to the keyring.  You can put whatever you want here for password functions;
    # even cleartext hardcoded passwords.  I've used keyring.
        return keyring.get_password("cowsay", "josh")

def smtp_connect() -> smtplib.SMTP:
    """ use global settings and return SMTP object"""
    smtp = smtplib.SMTP(GBL_SMTP_ADDRESS, GBL_SMTP_PORT)
    smtp.noop()
    # smtp.starttls()
    smtp.set_debuglevel(1)
    # smtp.login(GBL_SMTP_USER_NAME, get_passwd())
    return smtp

def gen_cowsay() -> str:
    # open p1 process
    p1 = subprocess.Popen(['/usr/bin/fortune'], stdout=subprocess.PIPE)
    # open p2 process, taking the input from p1
    p2 = subprocess.Popen(['/usr/bin/cowsay'], stdin=p1.stdout, stdout=subprocess.PIPE)
    # break p1 to fire p2
    p1.stdout.close()
    # the PIPE out from subprocess is bytes (b'') so we need to decode
    return p2.communicate()[0].decode("utf-8")


if __name__ == '__main__':
    smtp = smtp_connect()
    SUBJECT = 'cowsay daily'
    message = f'Subject: {SUBJECT}\n\n {gen_cowsay()}'
    smtp.sendmail(GBL_SMTP_USER_NAME, GBL_WORKEMAIL, message)
    smtp.quit()

