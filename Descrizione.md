# Shopping lists

## ER

![ER](D:\Programming\Web\Shopping_Lists\ER.png)





## Classi principali

### User

Gli utenti registrati vengono memorizzati usando questa entità.
Le proprietà sono:

- id (autogenerated)
- email (unica)
- password (memorizzata utilizzando bcrypt)
- firstname
- lastname
- is_admin (per distinguere gli amministratori dagli utenti normali)

Gli User possono creare liste e prodotti, invitare altri user, modificare liste e prodotti, caricare immagini...



### NV_User

Prima di venire registrati gli utenti devono confermare il proprio indirizzo email. Nel frattempo vengono memorizzati come NV_User.

- email (unica)
- firstname
- lastname
- password (memorizzata utilizzando bcrypt)
- verification_code: una stringa random utilizzata (insieme alla email) per verificare la registrazione

Una volta registrato (inserendo i dati come User), il corrispondente NV_User viene cancellato.



### List_category

Ogni lista appartiene ad una categoria di lista.
La categoria di lista definisce quali categorie di prodotto potranno essere aggiunte alla lista.
Per esempio, alla *lista1* di categoria *Cibo* si possono aggiungere solo prodotti dalle categorie *verdura, carne pasta, dessert, surgelati, condimenti*.
Tale corrispondenza di [*cat_lista*, *cat_prodotto*] è memorizzata nella tabella APP.LISTS_PRODUCTS_CATEGORIES.
Campi:

- id (autogenerated)
- name (unico)
- description



### Prod_category

Una categoria di prodotto può appartenere a più categorie di liste. Per esempio *TV* appartiene sia a *Elettronica* che a *Regali di Natale*.
Campi:

- id (autogenerated)
- name (unico)
- description
- renew_time: Indica dopo quanti giorni suggerire un reset della quantità acquistata. Per esempio, un prodotto appartenente alla Prod_category *carne*, che non viene acquistato da più di 4 giorni, attiverà un avviso nella lista corrispondente, consigliando di resettare a 0 la quantità acquistata.



### Product

Un prodotto può essere creato sia da User normali che da amministratori.

Campi:

- id (autogenerated)
- name
- description
- prod_category
- creator (utente che ha creato il prodotto)
- num_votes (quanti voti ha ricevuto)
- rating (da 0 a 5)



### List

Gli User normali possono creare, modificare, condividere ed eliminare liste.
Quando si aggiunge un prodotto alla lista si specifica anche la quantità.
Si possono aggiungere prodotti propri oppure prodotti pubblici (cioè quelli creati dagli admin).
I propri prodotti saranno visualizzabili agli utenti a cui condivido la lista, ma loro non potranno utilizzarli in liste proprie.

La condivisione delle liste avviene tramite inviti. Si invita un utente ad una lista specificando anche i privilegi che egli avrà, tra:

- AccessLevel.FULL (modificare la lista, aggiungere/rimuovere prodotti)
- AccessLevel.PRODUCTS (aggiungere/rimuovere prodotti)
- AccessLevel.READ (soltanto visualizzare e segnare cosa si ha acquistato)



Campi della lista:

- id (autogenerated)
- name
- description
- list_category
- owner (User che ha creato la lista)



### Message

All'interno di una lista i vari utenti possono lasciare dei messaggi.
Campi:

- list
- user
- text
- time



### List_anonymous

Gli utenti anonimi possono creare una lista, alla quale accederanno tramite id. L'id della lista viene infatti memorizzato anche a lato client in un cookie.
L' utente potrà aggiungere e rimuovere prodotti, oltre a poter modificare nome e descrizione della lista.
Campi:

- id (autogenerated)
- name
- description
- list_category
- last_seen: descrive l'ultima visita alla lista anonima. Se un utente rimuove il cookie, non potrà accedere più alla lista ed essa rimarrebbe inutilizzata nel database. Per questo, ogni tot liste inserite vengono rimosse quelle più vecchie di 1 anno.


