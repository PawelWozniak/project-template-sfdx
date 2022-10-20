## Deploy

```sfdx force:source:deploy --checkonly --verbose --sourcepath "." -u <target name>``` - deploy all metadata in the project
```sfdx force:source:deploy --checkonly --verbose --sourcepath "force-app" -u <target name>``` - deploy metadata from force-app folder only

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

## Delta Package  [SGD Dcumentation](https://github.com/scolladon/sfdx-git-delta#what-is-sfdx-git-delta)

```sfdx sgd:source:delta --from "HEAD~1" --to "HEAD" --output manifest-delta``` - generate package.xml based on changes from last commit.
```sfdx force:source:deploy --verbose --manifest "manifest-delta/package/package.xml" --checkonly -u <target name>``` - verify delta package on target org
```sfdx force:source:deploy --verbose --manifest "manifest-delta/package/package.xml --postdestructivechanges "manifest-delta/destructiveChanges/destructiveChanges.xml" --checkonly -u <target name>``` - verify delta package and destructive package.
