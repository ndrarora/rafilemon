RAOMON Script Configuration Files

1. OMSCRIPTS

omscripts:sn:script:outputtype(N/C)(Number/Character):Condition(NULL,=,<>,<,>,.T.,.F.):Value to Compare:


Weill email for True Condition
When condition is "Null" not comparison is made & no email is sent

2. OMRUNEVENT

omrunevent:name:sn(from first file):email add:email subj:email body:freq(1M,5M,10M,60M,1D)

(If no email add is given, email is not sent)
(multiple email address are seperated by ",")

3. OMINSDETAIL

ominsdetail:name:host:port:user:pass

4. OMUPLOADDB

omuploaddb:name:host:port:user:pass


5. OMDHISTORY

omdatastor:name,host,port,script,condition,value,date&time_local,date&time_server
