////////////////////  Torneo de Magos /////////////////////
class Mago{
    var property nombre
    var property resistenciaMagica  
    var property energiaMagica 
    var property reserva

    var property poderInato  // 1 al 10

    method poderInato(nuevoPoder) {
    if(!self.esPoderValido(nuevoPoder)) {
        self.error("El poder innato debe estar entre 1 y 10, recibido: " + nuevoPoder)
    }
    poderInato = nuevoPoder
    }

    method esPoderValido(poder) = poder.between(1, 10)

    var property objetosMagicos = []

    method poderTotal() = self.objetosMagicos().sum{un=>un.poder(self)} * self.poderInato()

    method desafiar(oponente) {
        if(oponente.esVencidoPor(self)) {
            // El mago ganador obtiene la energía mágica del perdedor
            energiaMagica = energiaMagica + oponente.energiaMagica()
            oponente.pierdePorDerrota()
        }
    }

    method esVencidoPor(oponente)

    method pierdePorDerrota(){}

    // Para el punto 3: un mago es su propio líder
    method lider() = self
}

class Aprendices inherits Mago{

    override method esVencidoPor(enemigo) = self.resistenciaMagica() < enemigo.poderTotal()  

    override method pierdePorDerrota() { energiaMagica = energiaMagica / 2 }
}

class Vetenaro inherits Mago{

    override method esVencidoPor(enemigo) = self.energiaMagica() * 1.5 < enemigo.poderTotal() 

    override method pierdePorDerrota()  { resistenciaMagica = resistenciaMagica / 4 }
}

class Inmortales inherits Mago{

    override method esVencidoPor(enemigo) = false 

    override method pierdePorDerrota() {} // Los inmortales no pierden nada

}

class ObjetoMagico{
    var property valorBase
    method poder(mago)
}


class Varita inherits ObjetoMagico{

    override method poder(mago) = if (mago.nombre().length().even()) valorBase*1.5  else valorBase
}

class Tunica inherits ObjetoMagico{

    override method poder(mago) = mago.resistenciaMagica()*2 + valorBase
}

class TunicaEpica inherits Tunica{

    override method poder(mago) = super(mago) + 10
}

class Amuletos inherits ObjetoMagico(valorBase = 0){

    override method poder(mago) = 200
}

class Ojota inherits ObjetoMagico{

    override method poder(mago) = mago.nombre().length() * 10
}

class GremioMagos{

    var property miembros = []

    // PUNTO 1: Constructor que valida mínimo 2 miembros
    method initialize(listaDeMiembros) {
        self.validarCantidadMinima(listaDeMiembros)
        miembros = listaDeMiembros
    }

    method validarCantidadMinima(listaMagos) {
        if(listaMagos.size() < 2) {
            self.error("Un gremio debe tener al menos 2 miembros")
        }
    }

    // Métodos básicos del gremio
    method poderTotal() = miembros.sum{miembro => miembro.poderTotal()}

    method reserva() = miembros.sum{miembro => miembro.reserva()}

    method cantidadMiembros() = miembros.size()

    // Método para agregar miembros después de la creación
    method agregarMiembro(nuevoMiembro) {
        miembros.add(nuevoMiembro)
    }

    // Método para quitar miembros (validando que no queden menos de 2)
    method quitarMiembro(miembro) {
        if(miembros.size() <= 2) {
            self.error("No se puede quitar el miembro. El gremio quedaría con menos de 2 miembros")
        }
        miembros.remove(miembro)
    }

    // Verificar si un mago pertenece al gremio
    method tieneMiembro(mago) = miembros.contains(mago)

    // ● El líder del gremio es el miembro con mayor poder total
    // Si el más poderoso es un gremio, el líder es el líder de ese gremio
    method lider() {
        const miembroMasPoderoso = miembros.max{miembro => miembro.poderTotal()}
        return miembroMasPoderoso.lider()
    }

    // ● Resistencia mágica total del gremio
    method resistenciaMagica() = miembros.sum{miembro => miembro.resistenciaMagica()}

    // ● Para vencer a un gremio: poder atacante > (resistencia total + resistencia líder)
    method resistenciaParaVencer() = self.resistenciaMagica() + self.lider().resistenciaMagica()

    // ● Condición para ser vencido por otro
    method esVencidoPor(atacante) = self.resistenciaParaVencer() < atacante.poderTotal()

    // ● Los gremios pueden desafiar a otros magos o gremios
    method desafiar(oponente) {
        if(oponente.esVencidoPor(self)) {
            // Los puntos de energía mágica van a la reserva del líder del gremio
            const energiaObtenida = oponente.energiaMagica()
            self.lider().reserva(self.lider().reserva() + energiaObtenida)
            oponente.pierdePorDerrota()
        }
    }

    // ● Al perder, cada mago pierde como si fuera individual
    method pierdePorDerrota() {
        miembros.forEach{miembro => miembro.pierdePorDerrota()}
    }

    // Energía mágica total del gremio
    method energiaMagica() = miembros.sum{miembro => miembro.energiaMagica()}

}

// Factory para crear gremios con validación
object gremioFactory {
    
    method crearGremio(listaDeMagos) {
        const nuevoGremio = new GremioMagos()
        nuevoGremio.initialize(listaDeMagos)
        return nuevoGremio
    }
    
}
