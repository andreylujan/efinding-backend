# Efinding


### Crear nueva organización

Teniendo la base de datos inicial, primero, entramos a la carpeta root y ejecutamos 

```sh
$ bundle exec rails c
```
Para entrara la consola de rails. Los pasos a seguir son los siguientes:
```ruby
org = Organization.create! name: "Echeckit Test", logo: "url opcional de logo"
```
Con esto creamos el objeto de más alto nivel, con el cual se relaciona casi todo.
Luego, creamos un "Role", lo que permite definir niveles de acceso de usuarios para esta organización.
```ruby
role = Role.create! name: "admin", organization: org
```
Con esto ya podemos generar un usuario de prueba. Ejemplo:
```ruby
user = User.create! first_name: "Pablo", last_name: "LLuch", password: "12345678", role: role, email: "test@ewin.cl"
```
Siguiente paso: Crear un "Tipo de reporte", en echeckit podía servir para tener reportes con distintos campos en una misma empresa, para moller me parece que se podría usar para distinguir a los reportes de los checklists sin tener que usar una table distinta
```ruby
report_type = ReportType.create! name: "Hallazgo", organization: org
```

### Configurar seciones app

La tabla encargada de hacer esto es "Section". El atributo section_type determina si una sección tiene galería, mapa o data parts. Section es una instancia de una sección de un determinado tipo.
Ejemplo:
```ruby
s1 = Section.create! name: "Mapa", section_type: :map, report_type: report_type
s2 = Section.create! name: "Galería", section_type: :gallery, report_type: report_type
s3 = Section.create! name: "Notas", section_type: :data_parts, report_type: report_type
```
s3, en este caso, sería la sección encargada de contener los DataParts.
Las posiciones tienen un campo "position" que serviría para cambiarlas de orden. Además existen métodos para facilitar esta pega. Podríamos, por ejemplo, hacer:
```ruby
s3.move_to_top
```
Con lo cual deja el "position" de s3 en 1 y aumenta los otros position para mantener un orden relativo.
Esto usa la gema  [ActsAsList], ver documentación online.
### Data Parts
La clase base de los data parts es "DataPart" (sorpresa). De esta clase derivan, actualmente, las siguientes clases:
* Comment - representa un campo de texto editable
* Label - Representa un texto no editable
* SearchableTable - Lista de items seleccionables, que se pueden además buscar
* Checklist, ChecklistItem y ChecklistOption - sirven para configurar checklists como el de Belltech.

Cada data part tiene, de forma importante, un campo "config" que es un JSON arbitrario, y que contiene información de cómo mostrar los data parts.
Adicionalmente existe un campo **required**, el cual define si un campo es obligatorio o no.

Ejemplos:
```ruby
Comment.create! name: "Nombre cliente", required: true, config: { multiline: false, type: "text" }, section: s3, organization: org
Comment.create! name: "Número de fono", required: false, config: { multiline: false, type: "number" }, section: s3, organization: org
```
Hay otros más complejos. Las tablas, por ejemplo, pueden extraer información desde algún modelo existente, o bien para un demo incluir la información dentro del mismo config. Por ejemplo, para Pausa:

```ruby
SearchableTable.new name: "Seleccionar Banco", organization: org, section: s3, config: {"source": {"collection_name": "pausa_categories"}}
```
Crea una tabla seleccionable apuntando a un dato "pausa_categories", el cual a su vez apunta a un modelo de tipo "OrganizationDatum" (explicaré después) que sirve para cargar datos de la API dinámicamente dependiendo del tipo de reporte. Para un demo simple, se pueden "hardcodear" datos así:
```ruby
SearchableTable.create! name: "Seleccionar Banco", organization: org, section: s3, config: {"source"=>{"models"=>[{"attributes"=>{"name"=>"Banco de Chile"}}, {"attributes"=>{"name"=>"BCI"}}, {"attributes"=>{"name"=>"Santander"}}, {"attributes"=>{"name"=>"BBVA"}}]}}
```
Esto se usó para Antalis. Al igual que las secciones, uno puede manejar la posición relativa de los data parts usando [ActsAsList].

#### Data parts numéricos

Para los DataParts de tipo "Comment" que se requiere que tengan un teclado numérico, basta con que el campo "config" tenga una propiedad "type": "number". Por ejemplo:

```ruby
Comment.create! organization_id: 3, section_id: 9, name: "Número de sillón", config: { "type" : "number", "hint" : "Ingrese el número de sillón" }
```

#### Mover data parts hacia arriba o hacia abajo

Como se menciona previamente, el ordenamiento de los data parts (según se visualiza en la aplicación) se hace utilizando los métodos que provee la gem  [ActsAsList]. Por ejemplo, para mover un data part cualquiera un puesto hacia más arriba:

```ruby
# Asumiendo que sabemos que el id es 137
c = Comment.find(137)
# Uno hacia arriba
c.move_higher
# Uno hacia abajo
c.move_lower
# Que sea el primero
c.move_to_top
```

### Configurar admin

MenuSection y MenuItem sirven para configurar lo que aparece en el menú. Basarse en los que ya existen, generalmente es casi "copy paste". Por ejemplo, para crear un menú para ver reportes:

```ruby
section = MenuSection.create! organization: org, name: "Reportes", icon: "file-text-o", admin_path: "echeckit.reportes"
item = MenuItem.create! name: "Lista", admin_path: "echeckit.reports.list", menu_section: section
```
Aquí lo crucial es el admin_path, lo cual determina lo que hará el admin. Se pueden ver los existentes y basarse en eso, ej: 
```ruby
ap Organization.find(1).menu_sections
```

#### Columnas de reportes

Para configurar las columnas y el orden en que aparecen en el admin, se usa ReportColumn. 

```ruby
column = ReportColumn.create! column_name: "Comuna", field_name: "marked_location_attributes.commune", report_type: report_type, data_type: :text
```

column_name determina el texto visible al usuario, field_name determina el lugar desde el que se extrae el dato (esto puede ser un campo de la columna o algo más complejo, estudiar ejemplos existentes)
Al igual que las otras cosas ordenables, existe una columna "position" para ordenar las columnas usando [ActsAsList].

[ActsAsList]: <https://github.com/swanandp/acts_as_list>
