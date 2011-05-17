package nl.igorski.lib.ui.forms

the igorski form package was developed with the ease of HTML forms in mind.
The components inherit many properties ( such as 'checked' and 'selected' ) from
their HTML counterparts and are custom skinnable by overriding their draw methods.

the BaseForm class uses the igorski Proxy class to serialize the form output
into JSON and receives backend validation results via the same format. See
the nl.igorski.lib.model package for details.

Viewing the ExampleForm class shows the lowdown on how to quickly get a fully
working dirty-validated form within your AS3 application. Please note that there
are many more developed form libraries available for AS3. This is a just a quick
way to get the most crudest of forms on screen and working. Note they were developed
with a webserver in mind and leave the pattern validation to the backend!