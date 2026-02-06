class NoEstaInvitado inherits Exception{}

const lengAntiguo = ["wollok","cpp","java"]

const lengModerno = ["ruby","python"]

class Empleado {
    const property lengConoce = []

    method aprendeLeng(lenguaje){
        lengConoce.add(lenguaje)
    }
    
    method conoceLengAntiguo() = lengAntiguo.any({ un => lengConoce.contains(un) })

    method conoceLengModerno() = lengModerno.any({ un => lengConoce.contains(un) })

    // Template Method: La lógica general de invitación
    // "Además, cualquier persona copada también está invitada" se ve en el || self.esCopado()
    method estaInvitado() = self.cumpleRequisitoDeInvitacion() || self.esCopado()

    // Métodos abstractos/hooks que deben implementar las subclases
    method cumpleRequisitoDeInvitacion() 
    method esCopado() = false // Por defecto no son copados salvo que la subclase diga lo contrario

    method numeroMesa() = self.lengModernoConoce()

    method lengModernoConoce() = lengModerno.filter{ un=>lengConoce.contains(un)}.size() 

    method regalo() = 1000 * self.lengModernoConoce()
}

class Desarrollador inherits Empleado {
    override method cumpleRequisitoDeInvitacion() = 
        lengConoce.contains("wollok") || self.conoceLengAntiguo()

    override method esCopado() = self.conoceLengAntiguo() && self.conoceLengModerno()
}

class Infra inherits Empleado {
    const experiencia

    override method cumpleRequisitoDeInvitacion() = lengConoce.size() >= 5

    override method esCopado() = experiencia > 10
}

class Jefe inherits Empleado {
    const property aCargo = []

    method tomarGente(empleado) {
        aCargo.add(empleado)
    }

    override method cumpleRequisitoDeInvitacion() = self.conoceLengAntiguo() && self.aCargoCopados()

    method aCargoCopados() = aCargo.all({ un => un.esCopado() })
    
    // Jefe no sobreescribe esCopado(), asique usa el false del padre (no se define copado para Jefe)

    override method numeroMesa() = 99

    override method regalo() = super() + (1000*aCargo.size()) 
}

class Empresa {
    const property empleados = []
}

class Organizador{
    var property empresa 

    method listaInvitados() = 
        empresa.empleados().filter{un=>un.estaInvitado()}
}


// segunda parte

class Fiesta{
    var property organizador

    var property mesas = []

    const costoFijo = 200000

    var property asistentes = []

    method costoFiesta() = costoFijo + (5000 * asistentes.size() )

    method registrar(persona) {
        if( !organizador.listaInvitados().contains(persona) ){
            throw new NoEstaInvitado(message="no esta invitado")
        }

        asistentes.add(persona)
        self.asignarMesa(persona)
    }

    method asignarMesa(persona){
        //persona.numeroMEsa() devuelve el numero de mesa que le corresponde
        const numeroMesa = persona.numeroMesa()

        if( !mesas.any({ unaMesa => unaMesa.numeroMesa() == numeroMesa }) ){
            const mesa = new Mesa(numeroMesa = numeroMesa)
            mesas.add(mesa)
        }
        const laMesa = mesas.find({ unaMesa => unaMesa.numeroMesa() == numeroMesa }) 
        laMesa.asistenteEnMesa().add(persona)
    }

    method balance() = asistentes.sum{un=>un.regalo()}  - self.costoFiesta()

    method fiestaExitosa() = self.balance() > 0 &&  (organizador.listaInvitados().size() == asistentes.size())
    // compara conjuntos:  organizador.listaInvitados().all{ i => asistentes.contains(i) }               
    method mesaMasAsistentes() = mesas.max{un=>un.asistenteEnMesa().size()}
} 

class Mesa{
    var property numeroMesa
    var property asistenteEnMesa = []
}