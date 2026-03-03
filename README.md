# Check Point - Lakera Guard Client Application Demostration deployment on Kubernetes Microk8S environment
The purpose of this repository is to provided a deployment demonstration of Check Points Lakera Guard offering in a Kubernetes MicroK8s environment.

The repository includes the Lakera Guard Client and Backend in a single Pod, Toolhive filesystem and fetch MCP servers and an ingress controller.


<Diagram to follow> 


Instructions:

* Install microK8s on your Ubuntu System if you have not done so already
```
sudo snap install microk8s --classic
```
* Clone this repository
```
git clone https://github.com/vmummer/cp-guard-k8s
```
* change into the cp-guard-k8s directory
```
cd cp-guard-k8s
```
* Run the setup script
``` 
./setup
```
* Load up the lab's aliase file to simplify command and task for this environment. You will need to reload this aliase file everytime you log out and log back in.
```
source cpalias.sh
```
* Note the last line showing the URL you could use to reach the cluster from your local browser.

Copy and past the following URL into your browser to access Laker Guard Demo http://172.29.11.127.nip.io     <<< Note your IP would be different >>>

* Use the cphelp command to provide command to assist in this demonstration.

```
cphelp
```
```
Check Point Lab Commands:     Ver: 1.0.0  
written by - Vince Mammoliti - vincem@checkpoint.com  

cphost           Shows the IP address of the Host used  
cpingress        Shows the IP address of the Ingress Controller used
cphelp           Alias Command to help with Check Point Lab
cpmetallb        Enables the MicroK8s Metallb with the External IP of the Host system
cplglog          Watch the Lakera Guard Application Logs

Kubectl Short Cuts
k                kubectl
ka               kubectl apply
kd               kubectl delete
kp               kubectl get pods -A
ks               kubectl get svc -A --output wide
kdwaf            kubectl delete POD {WAF POD Name} --force
```

* Verify the cluster is up and running
```
kp 
```
You should see somethign like the following:
```
NAMESPACE         NAME                                       READY   STATUS    RESTARTS   AGE

ingress           nginx-ingress-microk8s-controller-g429v    1/1     Running   0          23h
kube-system       calico-kube-controllers-5947598c79-l9dwz   1/1     Running   2          4d2h
kube-system       calico-node-5p6zj                          1/1     Running   2          4d2h
kube-system       coredns-79b94494c7-gpnbd                   1/1     Running   2          4d2h
kube-system       hostpath-provisioner-c778b7559-wggsl       1/1     Running   2          4d2h
lakera            guarddemo-b557d6644-l8q5f                  1/1     Running   2          3d23h
toolhive-system   fetch-0                                    1/1     Running   0          11m
toolhive-system   fetch-5489c4cc44-2hcp6                     1/1     Running   0          11m
toolhive-system   filesystem-0                               1/1     Running   2          3d23h
toolhive-system   filesystem-576b74976-gbcvk                 1/1     Running   0          11m
toolhive-system   toolhive-operator-54b88c7db6-5jkmq         1/1     Running   0          12m

```
```

