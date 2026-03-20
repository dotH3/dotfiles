## Reglas obligatorias

- NO ejecutar migraciones. Yo las ejecuto manualmente después.
- NO hacer commits.
- NO hacer push.
- NO modificar archivos que no estén directamente relacionados con la tarea.
- NO refactorizar, reordenar imports, formatear ni “mejorar” código fuera del scope.
- Limitar los cambios estrictamente a lo necesario para cumplir el requerimiento.

## Restricciones adicionales

- La codebase ya es grande y tiene patrones definidos. Basarse fuertemente en la implementación existente antes de proponer algo nuevo.
- Reutilizar servicios, helpers, estructuras, convenciones y flujos ya existentes siempre que sea posible.
- Si necesitás implementar algo y no encontrás un ejemplo claro en la codebase sobre cómo lo hacemos, preguntar antes de decidir un enfoque.
- Si es necesario tocar algo fuera del scope, pedir confirmación antes de hacerlo.
- No crear archivos nuevos salvo que sea estrictamente necesario.
- No cambiar nombres de variables, métodos o estructuras existentes sin motivo funcional.
- No introducir cambios cosméticos ni de estilo que generen ruido en el diff.
- Evita usar QueryBuilders en el backend, si crees que es la mejor opcion puedes comentarmelo
