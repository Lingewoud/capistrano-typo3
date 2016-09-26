# Capistrano-typo3 + Homestead

Als ontwikkelaar wil je in je eigen editor werken met de luxe dat je
wel de volledige TYPO3 Lamp stack tot je beschikking hebt.

Capistrano-typo3 integreert TYPO3.Homestead, een Vagrant machine van
@tuurlijk die ervoor zorgt dat een website die geschikt is voor CI met
Capistrano-typo3 ook heel makkelijk op een eigen machine geinstalleerd
kan worden.

TYPO3.Homestead bevat alle mogelijke hulpmiddelen voor TYPO3
en PHP ontwikkelaars, waaronder diverse php-versies en php-debugging
tools, maar ook o.a. MailHog, memcached, rabbitMQ, redis, elasticsearch.
Capistrano-typo3 installeert homestead en houdt de configuratie helemaal
vanilla. Lees alles over de mogelijkheden Homestead op de
[TYPO3.Homestead gitlab site](https://github.com/Tuurlijk/TYPO3.Homestead).

## Installatie

Als een site al geschikt is gemaakt voor Homestead moet je volgende
handelingen uitvoeren in Homestead op je eigen machine met de website te
installeren.

### 1. Clone de website en installeer de noodzakelijk gems

```
git clone -b developer git@gitlab.lingewoud.net:sites/site-t3.git
bundle install --path=vendor --binstubs
```

### 2. Draai het homestead setup script

```
./bin/cap homestead typo3:vagrant:setup_machine
```

Als er iets niet goed gaat kun je met het volgende commando de machine
verwijderen.

```
./bin/cap homestead typo3:vagrant:purge_machine
```

Je kunt vervolgens weer met een schone lei het commando

```
homestead:setup_machine
```
uitvoeren.

### 3. Installeer de site in homestead

```
./bin/cap homestead typo3:vagrant:setup_site
```

Als er iets niet goed gaat gebruik je het commando:

```
./bin/cap homestead typo3:vagrant:purge_site
```

Je kunt vervolgens weer met een schone lei het volgende commando
uitvoeren.

```
./bin/cap homestead typo3:vagrant:setup_site
```

### 4. Sychroniseer de live content bestanden

Houdt er rekening mee dat dit lang kan duren. Voer het onderstaande
commando uit om de bestanden vanuit de live installatie naar de vagrant
machine de synchroniseren:

```
./bin/cap homestead typo3:content:sync_files_from_production
```

## Gebruiken

### Vagrant machine starten/stoppen

Als Homestead geïnstalleerd is moet je de vagrant machine starten om met
de site te kunnen werken.

Open een terminal en cd naar de root directory van je TYPO3 project.
Vanuit hier type je ```vagrant up```. Wil je de vagrant weer stoppen
type dan ```vagrant halt```. Om te zien of vagrant draait type je
```vagrant status```.

Let op: in de huidige versie van Capistrano-typo3+homestead mag er maar
een vagrant machine tegelijk draaien.

### Site URL en broncode

Als vagrant draait kun je website openen via: http://local.typo3.org.

Als de website draait staat de TYPO3 code in de map
```[T3-project]/dummy```.

### Site database

De database is te benaderen via een ssh-tunnel. Aan de hand van Sequel
Pro leggen we uit hoe contact gemaakt kan worden met de database. Zie de
schermafbeelding hieronder:

![image](http://picdrop.t3lab.com/xZDfFGGnQL.png)

Maak een nieuwe profiel en vul de bestanden zoals hierboven. Het
password veld van de database moet gevuld worden met ```supersecret```.
De SSH Private is bij het maken van de machine gegenereerd. De ssh key
staat in de verborgen map
[T3-project]/.vagrant/machines/default/virtualbox/private_key

Kopieer het volledige pad van de private key en plak deze in Sequel Pro.

Als de vagrant machine draait geeft dit profiel toegang tot alle
databases.


### Datase en evt bestanden synchroniseren

Capistrano-typo3 gaat ervanuit dat database en de website content
bestanden van de live website altijd de laatste versie is.
Dit betekend dat op gezette momenten de ontwikkelaar de database en de
bestanden in z'n Homestead ontwikkelomgeving wil bijwerken met de
live versies. Dit kan met de volgende 2 losse commando's:

```
./bin/cap homestead typo3:content:sync_db_from_production
./bin/cap homestead typo3:content:sync_files_from_production
```

## Links
- [TYPO3.Homestead](https://github.com/Tuurlijk/TYPO3.Homestead)




























