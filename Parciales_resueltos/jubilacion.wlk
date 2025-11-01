const todosLosLenguajes = ["COBOL", "FORTRAN", "Pascal", "Python", "Ruby", "JavaScript"]
const lengAntiguo = ["COBOL", "FORTRAN", "Pascal"]
const lengModerno = todosLosLenguajes.filter { l => !lengAntiguo.contains(l) }

// --- Clase base común ---
class Empleado {
    var property programaEn = []

    var property esCopado = false

    method esInvitado() = self.esCopado()  // punto 3

    // aprender lenguaje (evita duplicados)  // punto 2
    method aprender(lenguaje) {
    if (!programaEn.contains(lenguaje)) { self.programaEn().add(lenguaje) }
    }
    
    // Contar lenguajes modernos que conoce
    method cantidadLenguajesModernos() = programaEn.count { l => lengModerno.contains(l) }
    
    // Número de mesa (por defecto igual a lenguajes modernos)
    method numeroMesa() = self.cantidadLenguajesModernos()
    
    // Monto del regalo
    method montoRegalo() = 1000 * self.cantidadLenguajesModernos()
}

// --- Desarrollador ---
class Desarrollador inherits Empleado {

    method conoceLenguajeAntiguo() = programaEn.any { l => lengAntiguo.contains(l) }
    method conoceLenguajeModerno() = programaEn.any { l => lengModerno.contains(l) }

    override method esCopado() = self.conoceLenguajeAntiguo() && self.conoceLenguajeModerno()

    override method esInvitado() =
    super() || programaEn.contains("Wollok") || self.conoceLenguajeAntiguo()
}

// --- Infraestructura ---
class Infra inherits Empleado {
    const experiencia = 0

    override method esCopado() = experiencia > 10

    override method esInvitado() = super() || programaEn.size() >= 5
}

// --- Jefe ---
class Jefe inherits Empleado {
    var property aCargo = []

    method conoceLenguajeAntiguo() = programaEn.any { l => lengAntiguo.contains(l) }
    method genteCopada() = aCargo.all { p => p.esCopado() }

    override method esInvitado() = super() || (self.conoceLenguajeAntiguo() && self.genteCopada())

    // Punto 1: tomar a cargo (sin duplicar; usa getter para encapsular)
    method tomarACargo(empleado) {
    if (!self.aCargo().contains(empleado)) { self.aCargo().add(empleado) }
    }
    
    // Los jefes van a la mesa 99
    override method numeroMesa() = 99
    
    // Los jefes regalan $1000 por lenguaje moderno + $1000 por empleado a cargo
    override method montoRegalo() = super() + (1000 * aCargo.size()) 
}

// --- Juan ---
object juan {

    method invita(persona) = persona.esInvitado()

    method  listaDeInvitados(empresa) = empresa.empleados().filter { unEmpl => self.invita(unEmpl) }
}

class Empresa{
    var property empleados = []
}

//////////////   Parte 2: La Fiesta   //////////////
object fiesta {
    const organizador = juan
    var property empresa = null
    const property costoFijo = 200000
    var property asistentes = []
    var property registroAsistencia = []  // Lista de objetos {empleado, mesa}
    
    // Obtener lista de invitados
    method listaDeInvitados() = organizador.listaDeInvitados(empresa)
    
    // Verificar si una persona está en la lista de invitados
    method estaInvitado(empleado) = self.listaDeInvitados().contains(empleado)
    
    // Permitir ingreso solo si está invitado
    method ingresarInvitado(empleado) {
        if (self.estaInvitado(empleado)) {
            if (!asistentes.contains(empleado)) {
                asistentes.add(empleado)
                // Crear registro de asistencia
                const registro = new RegistroAsistencia(empleado = empleado, mesa = empleado.numeroMesa())
                registroAsistencia.add(registro)
            }
        } else {
            self.error("La persona no está en la lista de invitados")
        }
    }
    
    // Calcular costo total de la fiesta
    method costoTotal() = costoFijo + (5000 * asistentes.size())
    
    // Calcular total de regalos recibidos
    method totalRegalos() = asistentes.sum { empleado => empleado.montoRegalo() }
    
    // Obtener registro de asistencia
    method obtenerRegistroAsistencia() = registroAsistencia
    
    // PUNTO 1: Registrar asistencia de una persona (verificando que esté invitada)
    method registrarAsistencia(empleado) {
        self.ingresarInvitado(empleado)  // Ya verifica que esté invitado
    }
    
    // PUNTO 2: Calcular balance de la fiesta (regalos - costo)
    method balanceFiesta() = self.totalRegalos() - self.costoTotal()
    
    // PUNTO 3: Saber si la fiesta fue un éxito
    method fueExito() = self.balanceFiesta() > 0 && self.todosLosInvitadosAsistieron()
    
    method todosLosInvitadosAsistieron() = 
        self.listaDeInvitados().all { invitado => asistentes.contains(invitado) }
    
    // PUNTO 4: Mesa con más asistentes

    //otra forma igual pero sin tantos variables intermedias
    /*method mesaConMasAsistentes() = 
        registroAsistencia.map { registro => registro.mesa() }.asSet().max { mesa => self.cantidadAsistentesEnMesa(mesa) }
    */

    method mesaConMasAsistentes() {
        const mesas = registroAsistencia.map { registro => registro.mesa() }
        const mesasUnicas = mesas.asSet()
        return mesasUnicas.max { mesa => self.cantidadAsistentesEnMesa(mesa) }
    }
    
    method cantidadAsistentesEnMesa(numeroMesa) = 
        registroAsistencia.count { registro => registro.mesa() == numeroMesa }
}

// Clase para el registro de asistencia
class RegistroAsistencia {
    const property empleado
    const property mesa
}

/*
¿Podría tener un jefe a su cargo a otro jefe? ¿Qué cambios implicaría hacer en la solución
 para contemplar dicho caso? ¿Qué situaciones se deberían evitar?

// Podría generar dependencias circulares en genteCopada()
method genteCopada() = aCargo.all { p => p.esCopado() }

⚠️ Situaciones que se deberían evitar:
1. Ciclos en la jerarquía
Jefe A a cargo de Jefe B
Jefe B a cargo de Jefe A
Resultado: Dependencia circular infinita

*/