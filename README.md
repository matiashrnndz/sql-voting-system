# sql_voting_system
[Project done on Nov 2018.]

Una organización con 1.500 afiliados desea implementar un sistema de votación electrónica de
forma de posibilitar la participación de sus afiliados independientemente del lugar físico donde se
encuentren.

Actualmente se permite votar en nombre de otras personas a través de un poder. Con los años se
ha generado un “comercio” de poderes que resulta negativo y se desea eliminar.

De los votantes se conoce su nombre, apellido, número de afiliado que lo identifica, cédula,
credencial, nombre de usuario y se lleva un historial de las cuotas mensuales pagas.

Cuando un usuario ingresa por primera vez, el sistema le mostrará un mensaje para que cambie la
contraseña para quedar habilitado para votar (ya que es un usuario administrativo el que define la
primera contraseña).

La organización desea implementar tres tipos de votaciones: directiva, aprobación de mociones
individual y selección de moción.

**Votación directiva**

Como máximo se presentan tres listas a la votación directiva. Cada lista propone sus integrantes a
las tres comisiones existentes (Comisión Directiva, Comisión Fiscal y Comisión Electoral). El
votante puede votar de forma cruzada, es decir, votar a la lista 1 a la comisión directiva pero a la
lista 3 a la comisión fiscal, y a la lista 2 en la comisión electoral. Una lista tiene un lema y en cada
comisión se proponen 10 integrantes. En todos los casos de votación, se incluye la opción “En
blanco”.

**Votación de aprobación de mociones individual**

Una votación de este tipo consiste en una serie de mociones (nombre, texto descriptivo) y cada
una puede votarse como aprobada, como rechazada o en blanco. Como máximo pueden
someterse 10 mociones en una instancia de votación.

**Votación de selección de moción**

Una votación de este tipo, consiste en una serie de máximo diez mociones y el votante vota
aprobar únicamente una de ellas (o rechazarlas todas). También puede abstenerse de decidir.

La votación tiene cuatro posibles estados: Habilitada (la gente puede votar), Borrador (está siendo
creada o modificada), Cerrada (cuando se hace el recuento la votación se cierra y no es factible
seguir votando) y Publicada (los votantes pueden ingresar al sistema y ver el resultado de la
votación que ha sido llevada a cabo). Si la votación está cerrada o publicada, no puede volver a
abrirse o ser borrador. Una vez que la votación está habilitada solo es posible cerrarla. Solamente
puede estar habilitada una votación a la vez. Cada votación tiene una fecha/hora de inicio y una
fecha/hora de finalización. Solamente los afiliados integrantes de la comisión electoral podrán
crear, modificar o eliminar las votaciones.

El empleado administrativo del partido (no es necesariamente un afiliado), es el encargado de
gestionar el padrón electoral. También puede inhabilitar a algún afiliado en caso de atraso de tres
meses en la cuota.

Una persona no puede votar dos veces a una misma votación y debe garantizarse que lo que ha
votado cada votante sea por siempre secreto, es decir, que no pueda saberse quién ha votado
qué.

Es costumbre que cuando se realiza la votación de directiva, se haga un gran evento en alguna
ciudad de nuestro país. Para ese evento, suelen desplazarse un cuarto de los afiliados. Corre por
cuenta de la administración la organización de dicho evento.
Se ha solicitado que el sistema permita registrar las compras realizadas para cada evento,
detallando la fecha, la moneda que ha sido utilizada, el monto y el administrativo responsable.
Se ofrece la posibilidad de gestionar el hospedaje para los afiliados que participan y sus
acompañantes. Las habitaciones posibles son simple, doble, triple y suite.

Se requiere poder registrar los afiliados que han dejado de serlo, incluyendo la fecha y el motivo
de desafiliación.

Cada vez que se modifiquen los datos de algún votante, se requiere que quede registrado quién
hizo el cambio, la fecha y la hora.

**Se realizarán los siguientes requerimientos:**

**1. Control de padrón:** Proveer un servicio que retorne cuántos votantes se encuentran
habilitados para votar.

**2. Cierre de votación:** Proveer un servicio que permita a un usuario cerrar una votación y
realizar el conteo de votos. El usuario debe ser integrante de la comisión electoral actual.

**3. Control de votación de usuario:** Proveer un servicio que reciba como parámetro un
usuario y una votación, y retorne si el usuario ha votado o no en dicha votación.

**4. Resumen de votaciones:** Proveer un servicio que dado un periodo, retorne un resumen
de todas las votaciones realizadas durante el mismo, incluyendo los porcentajes de voto de
cada opción, las cantidades de votos de cada opción y la fecha de la votación. Se requiere
que se agrupe por tipo de votación y que el orden vaya de la más reciente a la más
antigua.
Importante: Se requiere que los datos del resumen se materialicen y se retornen en caso de que los
datos para el periodo solicitado estén disponibles. Si el proceso se interrumpe por algún motivo, se
espera que al reiniciarse el proceso no se inicie desde 0.

**5. Eliminación de votación:** Proveer un servicio que dada una votación, borre la misma
incluyendo todo lo que ha implicado (no implica borrar los usuarios que han votado) de
forma que no quede traza de su existencia. Dicho servicio solo puede ser ejecutado por un
usuario integrante de la comisión electoral actual.
Importante: Si el proceso se interrumpe por algún motivo, se espera que no queden inconsistencias.

**6. Resumen de gastos:** Proveer un servicio que dado un periodo, retorne el resumen de
gastos en moneda nacional y en dólares, desglosando los gastos realizados por evento.
Para ello el sistema debe permite registrar el tipo de cambio.

**7. Baja de usuario:** Proveer un servicio que dado un usuario, lo de baja del sistema.
