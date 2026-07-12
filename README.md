# cloud-systems-local-project

Questa repository contiene la parte locale del progetto di Sistemi Cloud.

## Struttura della repository

```
├── repo-setup
│   ├── gitea_token
│   ├── output.tf
│   ├── postgre-pass.txt
│   ├── repo.tf
│   ├── ssh_id
│   ├── ssh_id.pub
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   └── variables.tf
└── Sources-to-copy
    ├── Application
    │   ├── backend
    │   │   ├── Dockerfile
    │   │   ├── main.py
    │   │   └── requirements.txt
    │   ├── frontend
    │   │   ├── Dockerfile
    │   │   ├── index.html
    │   │   └── nginx.conf
    │   ├── k8s
    │   │   ├── backend-deployment.yaml
    │   │   ├── backend-scaling.yaml
    │   │   ├── backend-service.yaml
    │   │   ├── frontend-deployment.yaml
    │   │   ├── frontend-scaling.yaml
    │   │   ├── frontend-service.yaml
    │   │   ├── ingress.yaml
    │   │   ├── postgres-persistentvolume.yaml
    │   │   ├── postgres-service.yaml
    │   │   └── postgres-statefulset.yaml
    │   └── workflows
    │       └── ci-cd.yaml
    ├── Infrastructure
    │   ├── ansible
    │   │   ├── build-cluster.yaml
    │   │   ├── build-registry.yaml
    │   │   ├── install-k8s.yaml
    │   │   └── setup-lb.yaml
    │   ├── terraform
    │   │   ├── cloud-init.tftpl
    │   │   ├── daemon.tftpl
    │   │   ├── haproxy.tftpl
    │   │   ├── hosts-containerd.tftpl
    │   │   ├── hosts.tftpl
    │   │   ├── main.tf
    │   │   ├── output.tf
    │   │   ├── provider.tf
    │   │   └── variables.tf
    │   └── workflows
    │       ├── deploy.yaml
    │       ├── destroy.yaml
    │       └── plan.yaml
    └── protection.tf

```

La repository contiene due folder:

1. `repo-setup`, impiegato per la creazione e la gestione delle repository Gitea;
2. `Sources-to-copy`, che contiene i sorgenti da copiare nelle repository create con `repo-setup`.

## Funzionamento del progetto locale

Il progetto locale simula il funzionamento di un'infrastruttura distribuita simulata con istanze generate mediante Multipass, un hypervisor locale. La gestione dell'infrastruttura è affidata ad una repository locale ospitata su Gitea, mentre un'ulteriore repository gestisce il deployment dell'applicazione su di essa. In questo caso, l'applicazione è un URL Shortener, con front-end, back-end e database PostgreSQL.

### Setup di Gitea

Le repository sono ospitate su Gitea. Pertanto, è necessario installare Gitea e proseguire con il setup, come specifica la documentazione ufficiale [qui](https://docs.gitea.com/installation/). Successivamente, è necessario impostare il database utilizzato da Gitea, sempre utilizzando la [documentazione ufficiale](https://docs.gitea.com/installation/database-prep).

Una volta aver impostato Gitea e creato l'utente, è necessario installare un **Gitea runner**, un daemon che si occuperà di eseguire i workflow delle repository. Per fare ciò basta eseguire i seguenti step:

- scaricare il runner per il proprio sistema operativo da [qui](https://about.gitea.com/products/runner/);
- aggiungere i permessi di esecuzione al runner. In sistemi POSIX-compliant basta usare `chmod +x <nome_eseguibile>`;
- andare su Gitea in `Account > Impostazioni > Azioni > Runners` e cliccare su `Create new Runner`. Apparirà un registration token da copiare;
- eseugire il runner con argomento `register`. Per gli step di configurazione del runner, bisogna specificare:
  - dominio di Gitea, `http://localhost:3000` in setup regolari;
  - token di registrazione, recuperato precedentemente;
  - nome del runner, arbitrario;
  - etichette del runner. Qui è importante specificare solo `self-hosted`.

Una volta registrato, il runner può essere mandato in esecuzione con argomento `daemon`: il runner attenderà, così, le richieste dei workflow, eseguendole.

<video src="runner.mp4" controls></video>

### Setup delle repository

Le repository Gitea possono essere gestite mediante i sorgenti OpenTofu nella cartella `repo-setup`. Requisito fondamentale è che all'interno della cartella vi siano i seguenti file:

- `gitea_token`, file che contiene il token dell'account Gitea per la creazione di repository. Il token può essere creato andando su `Account > Impostazioni > Applicazioni > Genera Nuovo Token`. Il token deve avere **almeno** i permessi per la creazione e la gestione delle repository. Per semplicità, si può anche creare un token con permessi di lettura e scrittura su tutti gli elementi specificati alla creazioen del token, dato che Gitea è self-hosted sulla macchina. In setup condivisi, bisogna definire con maggiore granularità i permessi del token seguendo la documentazione;
- `postgre-pass.txt`, che contiene la password del database PostgreSQL da inserire come segreto della repository di infrastruttura. Chiaramente, **salvare la password in clear-text è un approccio insicuro**, e ricordo che il progetto è solo a scopi dimostrativi;
- `ssh_id` e `ssh_id.pub`, chiavi SSH da inserire sempre come segreto della repository di infrastruttura. Le chiavi possono essere create con il comando `ssh-keygen -t ed25519 -f ssh_id -N ""`;
- Gitea dev'essere ospitato alla porta 3000. In alternativa, andare nel file `variables.tf` e cambiare la porta dell'URL;
- la variabile `gitea_username` deve corrispondere allo username dell'utente Gitea creato, cambiando il valore default presente in `variables.tf`.

A questo punto, applicando i sorgenti OpenTofu è possibile creare le repository. Come output della generazione vengono forniti i link per la clonazione delle repository.

<video src="repo-run.mp4" controls></video>

### Repository dell'infrastruttura

All'interno della repository  `local-infrastructure` vanno copiati i sorgenti presenti in `Sources-to-copy/Infrastructure`, cartella che include i sorgenti e workflow per la generazione dell'infrastruttura locale. Tale infrastruttura è realizzata mediante istanze Multipass. La struttura della repo, dopo la copia dei file, risulta come a seguire:

```
├── ansible
│   ├── build-cluster.yaml
│   ├── build-registry.yaml
│   ├── install-k8s.yaml
│   └── setup-lb.yaml
├── .gitea
│   └── workflows
│       ├── deploy.yaml
│       ├── destroy.yaml
│       └── plan.yaml
└── terraform
    ├── cloud-init.tftpl
    ├── daemon.tftpl
    ├── haproxy.tftpl
    ├── hosts-containerd.tftpl
    ├── hosts.tftpl
    ├── main.tf
    ├── output.tf
    ├── provider.tf
    └── variables.tf
```

La cartella `terraform` permette la creazione di un'infrastruttura costituita dai seguenti elementi:

1. due worker;
2. un control plane;
3. un registry;
4. un load balancer.

La creazione dell'infrastruttura porta anche alla creazione di alcuni file nella directory `~/tofu-gen`. È opportuno creare questa directory **prima** di applicare il piano di OpenTofu per evitare problemi relativi all'esistenza della directory. In particolare, nella cartella vengono creati i seguenti file:

- `hosts.ini`, contenente l'inventario necessario per la configurazione dei nodi mediante Ansible;
- `haproxy.cfg`, necessario per la configurazione del load balancer tramite HAProxy;
- `hosts-contanerd.toml`, per la configurazione del registry privato per i nodi del cluster Kubernetes;
- `cloud-init.yaml`, per fornire la chiave SSH pubblica alle istanze multipass;
- `daemon.json`, da copiare al path dell'host `/etc/docker/daemon.json` per far sì che sia possibile caricare le immagini nel registry privato.

La cartella `ansible` include i playbook di Ansible per la configurazione dei nodi:

- `install-k8s.yaml` installa Kubernetes sui nodi del cluster, configurando anche il supporto al registry privato insicuro;
- `build-cluster.yaml` inizializza il cluster Kubernetes, installando nel cluster anche Flannel, Metrics Server e l'Ingress Controller. In questo modo, il cluster ha supporto per lo scaling orizzontale dei Pod e per il load balancing;
- `build-registry.yaml` imposta il registro privato installando l'immagine Docker necessaria;
- `setup-lb.yaml` crea il load balancer, impostando il file di configurazione in virtù dei nodi creati.

La cartella `.gitea/workflows` contiene i workflow di Gitea per l'aggiornamento automatico dell'infrastruttura:

1. il workflow `plan.yaml` viene avviato solamente se viene aggiunto una Pull Request. In questo caso, commenta la Pull Request con il piano di OpenTofu;
2. il workflow `deploy.yaml` esegue il deployment dell'infrastruttura, creando le istanze e lanciando i playbook di Ansible. Inoltre, crea il segreto del cluster Kubernetes, ossia la password per il deployment del database PostgreSQL;
3. il workflow `destroy.yaml` distrugge l'infrastruttura.

Di default, il repository non supporta alcun meccanismo di protezione della repository. Tuttavia, copiando il file `protection.tf` dalla cartella `Sources-to-copy` nella cartella `repo-setup` e riapplicando il piano OpenTofu, la repository `local-infrastructure` avrà una branch protection per il main che impedisce push diretti.

> Nota: di per sé la protezione del branch su Gitea così configurata nasconde alcuni problemi. Infatti, anche se si specifica che l'amministratore della repository può forzare il merge, con `required_approvals = 1` l'admin **non** può fare il merge delle proprie Pull Request. Pertanto, ai fini meramente dimostrativi del funzionamento del workflow `plan.yaml`, la protection ha questo parametro impostato a zero.

### Repository dell'applicazione

La repository dell'applicazione `shortener-application` conterrà i sorgenti presenti in `Sources-to-copy/Application`, al fine di ottenere la seguente struttura:

```
├── backend
│   ├── Dockerfile
│   ├── main.py
│   └── requirements.txt
├── frontend
│   ├── Dockerfile
│   ├── index.html
│   └── nginx.conf
├── .gitea
│   └── workflows
│       └── ci-cd.yaml
└── k8s
    ├── backend-deployment.yaml
    ├── backend-scaling.yaml
    ├── backend-service.yaml
    ├── frontend-deployment.yaml
    ├── frontend-scaling.yaml
    ├── frontend-service.yaml
    ├── ingress.yaml
    ├── postgres-persistentvolume.yaml
    ├── postgres-service.yaml
    └── postgres-statefulset.yaml
```

Le cartelle `backend` e `frontend` contengono i sorgenti e i Dockerfile necessari per la costruzione delle immagini dei microservizi. La cartella `k8s`, invece, contiene i manifest Kubernetes con le specifiche seguenti:

- deployment delle applicazioni di front-end e back-end, con i relativi servizi Kubernetes ClusterIP per la comunicazione tra i microservizi e le specifiche di scaling orizzontale;
- lo StatefulSet per il database PostgreSQL per la creazione del database PostgreSQL, con il PersistentVolume per montare il disco e il servizio Kubernetes ClusterIP per la comunicazione con il backend;
- `ingress.yaml` per il servizio Ingress, al fine di definire l'indirizzamento del traffico a front-end e backend.

Il workflow presente in `.gitea/workflows` permette il deployment dell'applicazione. Nel dettaglio:

- controlla se sono presenti modifiche a front-end e back-end, costruendo le immagini Docker solamente nel caso in cui i sorgenti sono modificati e caricandole al registry in caso positivo;
- riempie il manifest di front-end e back-end per definire l'IP del registry e il tag dell'immagine da pullare. Nello specifico, per non fare *hard-coding* dei valori di indirizzo IP e non usare il tag latest per ottenere tracciamento delle applicazioni dei manifest, si adotta una soluzione maggiormente flessibile, con la sostituzione dinamica di indirizzo IP del registry e tag dell'immagine;
- applica i manifest.

Il workflow si attiva alle modifiche della repo.

### Costruire l'infrastruttura

Per costruire l'infrastruttura, è sufficiente copiare i file:

<video src="copy-files.mp4" controls></video>

Una volta copiati, basta pushare le modifiche delle singole repository su Gitea usando i comandi git (`git add`, `git commit` e `git push`. Il push chiederà l'inserimento di username e password dell'utenza Gitea creata). Affinché i workflow possano essere eseguiti, bisogna lanciare il runner con argomento `daemon`.

### Stress-testing

Per porre sotto stress l'applicativo, basta lanciare un pod che inoltra molteplici richieste al back-end:

```sh
kubectl run url-stress-test --image=busybox:latest --restart=Never -- \
sh -c "while true; do wget -q -O- http://backend:8000/path-something > /dev/null; sleep 0.0005; done"
```

È importante specificare il file kubeconfig, reperibile alla cartella `~/tofu-gen/kubeconfig`. Si può monitorare il comportamento dello scaling orizzontale con:

```sh
kubectl get hpa --watch
```

Infine, per distruggere il pod di test:

```sh
kubectl delete pod url-stress-test
```

## Distruzione del progetto

Per distruggere il progetto, è sufficiente:

- distruggere l'infrastruttura lanciando manualmente il workflow `destroy` nella repository `local-infrastructure`;
- distruggere le repository con `tofu destroy` nella cartella `repo-setup`.

