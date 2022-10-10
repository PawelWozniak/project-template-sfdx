## Deploy
```sfdx force:source:deploy --checkonly --verbose --sourcepath "."``` - deploy all metadata

## Source Tracking Orgs (Sandbox, Scratch Org)
```sfdx force:source:status```  
```sfdx force:source:status --remote```  
```sfdx force:source:status --local```  
```sfdx force:source:push```  
```sfdx force:source:push -f```  
```sfdx force:source:pull```  
```sfdx force:source:ignored:list```  

## Tests
```sfdx force:apex:test:run --codecoverage --resultformat human --testlevel RunLocalTests```
