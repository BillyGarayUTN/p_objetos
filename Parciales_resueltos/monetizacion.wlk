// plataforma de Pago
const tagsModa = #{"ropa", "accesorios", "calzado"}
class Contenidos{

    var property monetizacion

    var property tags = []

    var property titulo

    var property cantVistas

    var property esOfensivo

    var property dineroGanado = 0

    method cobrarPlus() = if( self.esPopular() ) 2000 else 0

    method esPopular() 

    method recaudacionMax()

    method cambiarMonetizacion(nuevaMonetizacion) {
        if (nuevaMonetizacion.puedeSerMonetizado(self)) {
            monetizacion = nuevaMonetizacion
            dineroGanado = 0
        } else {
            self.error("No se puede aplicar esta monetización a este contenido")
        }
    }

    method recaudar() {
        dineroGanado = monetizacion.cobra(self)
    }

    // PUNTO 1: Calcular el total recaudado por un contenido
    method totalRecaudado() = monetizacion.cobra(self)

    method esReproducible() = false

}
class Videos inherits Contenidos{

    override method esPopular() = self.cantVistas() > 10000

    override method recaudacionMax() = 10000

    override method esReproducible() = true
}


class Imagenes inherits Contenidos{

    override method esPopular() =  tagsModa.all{ un=> self.tags().contains(un)}

    override method recaudacionMax() = 4000
}

// Monetizacion

class Monetizacion{
    
    method cobra(contenido) 

    method puedeSerMonetizado(contenido)
}

class Publicidad inherits Monetizacion{

    override method cobra(contenido) = (contenido.cantVistas() * 0.05 + contenido.cobrarPlus() ).min(self.recaudacionMax(contenido))

    method recaudacionMax(contenido) = contenido.recaudacionMax()

    override method puedeSerMonetizado(contenido) = !contenido.esOfensivo()
}

class Donacion inherits Monetizacion{
    var property montoAcumulado = 0

    method recibirDonacion(monto) {
        montoAcumulado += monto.max(0)
    }

    override method cobra(contenido) = montoAcumulado

    override method puedeSerMonetizado(contenido) = true
}

class Descarga inherits Monetizacion{
    var property precio

    override method cobra(contenido) = precio * contenido.cantVistas()

    override method puedeSerMonetizado(contenido) = contenido.esPopular()
}

// punto 4
class Alquiler inherits Descarga{
    override method precio() = 1.max(super())
        // Punto 4 
    override method puedeSerMonetizado(contenido) = super(contenido) && contenido.esReproducible()
}

// Usuario 

class Usuario{

    var property contenidos = []

    var property nombre

    var property email

    var property verificado = false

    method subirContenido(contenido) {
        contenidos.add(contenido)
    }

    // PUNTO 3: Permitir que un usuario publique un nuevo contenido con monetización
    method publicarContenido(contenido, monetizacion) {
        if (monetizacion.puedeSerMonetizado(contenido)) {
            contenido.monetizacion(monetizacion)
            self.subirContenido(contenido)
        } else {
            self.error("No se puede aplicar esta monetización al contenido")
        }
    }

    // PUNTO 2a: Saldo total de un usuario
    method saldoTotal() = contenidos.sum({ contenido => contenido.totalRecaudado() })

    method recaudacionTotal() = contenidos.sum({ contenido => contenido.dineroGanado() })

    method contenidosPopulares() = contenidos.filter({ contenido => contenido.esPopular() })

    method verificarUsuario() {
        verificado = true
    }

}

// Sistema/Plataforma para consultas globales
object plataforma {
    
    var property usuarios = []
    
    method registrarUsuario(usuario) {
        usuarios.add(usuario)
    }
    
    // PUNTO 2b: Email de los 100 usuarios verificados con mayor saldo total
    method emailsTop100UsuariosVerificados() = 
        usuarios.filter({ usuario => usuario.verificado() })
                .sortedBy({ u1,u2 => u1.saldoTotal()>u2.saldoTotal() })
                .take(100)
                .map({ usuario => usuario.email() })


    // 2 c
    // Cantidad de usuarios que tienen 10 o más contenidos populares
    method superUsuarios() = usuarios.count{un => un.contenidosPopulares().size() >= 10}
}
/*
Respuesta al Punto 5:
5a. Facilidad de implementación de requerimientos:
🟢 MÁS FÁCIL: i. Agregar un nuevo tipo de contenido
Por qué es fácil:

✅ Herencia bien diseñada: Solo crear una nueva clase que herede de Contenidos
✅ Polimorfismo: Los métodos esPopular() y recaudacionMax() ya están definidos como abstractos
✅ Integración automática: El resto del sistema funciona sin cambios gracias al polimorfismo
Conceptos del paradigma:

Herencia: Reutiliza toda la funcionalidad base
Polimorfismo: Se integra automáticamente con las monetizaciones
Encapsulamiento: Solo necesita implementar su lógica específica
Ejemplo:


class Podcast inherits Contenidos {    override method esPopular() = cantVistas() > 5000    override method recaudacionMax() = 6000}
🔴 MÁS DIFÍCIL: ii. Permitir cambiar el tipo de un contenido
Por qué es muy difícil:

❌ Violación de identidad: En POO, el tipo es parte fundamental del objeto
❌ Pérdida de estado: Propiedades específicas del tipo se perderían
❌ Incompatibilidad de monetizaciones: Un video con alquiler no puede ser imagen
Conceptos del paradigma violados:

Encapsulamiento: Expone la estructura interna del objeto
Inmutabilidad de tipo: Los objetos no cambian su clase en runtime
Polimorfismo: Se rompe la consistencia de comportamiento
Alternativas más apropiadas:

Crear un nuevo objeto del tipo deseado
Usar composición en lugar de herencia
Implementar un patrón State para comportamientos dinámicos
🟡 INTERMEDIO: iii. Agregar estado "verificación fallida"
Por qué es moderadamente fácil:

✅ Extensión simple: Agregar nueva propiedad al Usuario
✅ Validación existente: Ya hay lógica similar en publicarContenido()
⚠️ Impacto múltiple: Afecta varios métodos existentes
Implementación:

*/
// 5b. Mayor aprovechamiento del polimorfismo:

/*
✅ Interfaz uniforme: Todos implementan cobra() y puedeSerMonetizado()

✅ Comportamiento diferenciado: Cada estrategia tiene su lógica única:

Publicidad: Calcula por vistas + plus con límites
Donacion: Acumula montos externos
Descarga/Alquiler: Precio fijo × vistas con restricciones
✅ Transparencia para el cliente: El contenido no necesita saber qué tipo de monetización usa:


method totalRecaudado() = monetizacion.cobra(self)  // ¡Polimorfismo puro!
✅ Extensibilidad: Agregar nuevas estrategias (como Alquiler) no requiere cambios en el resto del código

✅ Sustitución: Se puede cambiar monetización en runtime manteniendo el mismo comportamiento
*/