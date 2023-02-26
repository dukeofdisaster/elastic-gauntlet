#!/usr/bin/python
# Simple Python script designed to write to the local Syslog file in CEF format on an Azure Ubuntu 18.04 VM.
# Frank Cardinale, April 2020

# Importing the libraries used in the script
import random
import syslog
import time

# Simple list that contains usernames that will be randomly selected and then output to the "duser" CEF field.
usernames = ['Frank', 'John', 'Joe', 'Tony', 'Mario', 'James', 'Chris', 'Mary', 'Rose', 'Jennifer', 'Amanda', 'Andrea', 'Lina']

# Simple list that contains authentication event outcomes that will be randomly selected and then output to the CEF "msg" field.
message = ['Login_Success', 'Login_Failure']

# Endless loop that will run the below every five minutes.
while True:

    # Assigning a random value from the above lists to the two variables that will be used to write to the Syslog file.
    selected_user = random.choice(usernames)
    selected_message = random.choice(message)

# Assigning a random integer value from 1-255 that will be appended to the IP addresses written to the Syslog file.
    ip = str(random.randint(1,255))
    ip2 = str(random.randint(1,255))

# The full Syslog message that will be written.   
    syslog_message = "CEF:0|Seamless Security Solutions|Streamlined Security Product|1.0|1000|Authentication Event|10|src=167.0.0." + ip + " dst=10.0.0." + ip + " duser=" + selected_user + " msg=" + selected_message

# Writing the event to the Syslog file.
    syslog.openlog(facility=syslog.LOG_LOCAL7)
    syslog.syslog(syslog.LOG_NOTICE, syslog_message)

# Pausing the loop for five minutes.
    time.sleep(300)

# End of script
