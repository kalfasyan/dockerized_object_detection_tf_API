import re
import subprocess

cmd="sudo nvidia-docker exec -it yannis ls training/ | grep '.index'"
ps = subprocess.Popen(cmd,shell=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
output = ps.communicate()[0].split()[-1]
to_return = re.findall(r'\d+', output)[0]
exit(to_return)
