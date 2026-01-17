class NoEstaInvitado inherits Exception{}

const lenguajesModernos = ["wollok", "kotlin", "typescript"]
const lenguajesAntiguos = ["cobol", "smalltalk", "pascal", "fortran"]


class Organizador{
    var property empresa

    method listaInvitados() = empresa.empleados().filter{uno=>uno.estaInvitado()}
}

object empresa{
    var property empleados = []
}
class Persona{

    var property lenguajesConoce = []
    
    method estaInvitado() = self.esCopado()
    
    method aprenderLenguaje(lenguaje) {
        lenguajesConoce.add(lenguaje)
    }
    
    method esCopado()

    method mesaAsignada() = self.cantidadLenguajesModernos()

    method cantidadLenguajesModernos() = lenguajesModernos.count{leng=>lenguajesConoce.contains(leng)}

    method regalo() = self.cantidadLenguajesModernos() * 1000
}

class Desarrollador inherits Persona{

    override method estaInvitado() = lenguajesConoce.contains("wollok") || lenguajesAntiguos.any{leng=>lenguajesConoce.contains(leng) }

    override method esCopado() = 
        lenguajesAntiguos.any{leng=>lenguajesConoce.contains(leng) } &&
        lenguajesModernos.any{leng=>lenguajesConoce.contains(leng) }
}

class Infra inherits Persona{

    var property experiencia

    override method estaInvitado() = lenguajesConoce.size() >= 5

    override method esCopado() = experiencia > 10
}

class Jefe inherits Persona{
    
    var property aCargo = []

    override method estaInvitado() = lenguajesAntiguos.any{leng=>lenguajesConoce.contains(leng)} && self.tieneACargoCopados()

    method tieneACargoCopados() = aCargo.all{uno=>uno.esCopado()}

    method tomarACargo(persona) {
        aCargo.add(persona)
    }
    
    override method mesaAsignada() = 99

    override method esCopado() = false // Los jefes no se consideran copados automáticamente

    override method regalo() = super() + (aCargo.size()*1000)

}

class Fiesta{
    var property organizador

    method costoFiesta() = 200000 + (self.presentes().size() *5000)

    var property presentes = []
    method asistieron(asistente){ 
        if(self.listaInvitados().contains(asistente)){  
            presentes.add(asistente)
        }
        else{
            throw new NoEstaInvitado(message=" No esta invitado")
        }
    }
    method listaInvitados() = organizador.listaInvitados()

    method balance() = presentes.sum{un=>un.regalo()} - self.costoFiesta()

    method fiestaExitosa() = self.balance() > 0 && self.listaInvitados().all{invitado=>presentes.contains(invitado)}

    method mesaConMasAsistentes() {
        const mesas = presentes.map{uno=>uno.mesaAsignada()}
        const mesasUnicas = mesas.asSet()
        return mesasUnicas.max{ unaMesa=>self.cantidadAsistentesPorMesa(unaMesa)} 
    }

    // method mesaConMasAsistentes() = 
    // presentes.map{uno=>uno.mesaAsignada()}.asSet().max{unaMesa=>self.cantidadAsistentesPorMesa(unaMesa)}    

    method cantidadAsistentesPorMesa(mesa) = presentes.count{unPresente=>unPresente.mesaAsignada() == mesa}
}
