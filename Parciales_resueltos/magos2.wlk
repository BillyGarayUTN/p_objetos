class Mago{
    var property nombre

    var property resistencia

    var property energiaMagica

    var property poderInato
    
    method initialize() { // cuando se crea el objeto
        if(!self.esPoderValido(poderInato)) {
            self.error("El poder innato debe estar entre 1 y 10, recibido: " + poderInato)
        }
    }
    
    method esPoderValido(poder) = poder.between(1, 10)

    method poderInato(nuevoPoder) {  // para las modificaciones posteriores
        if(!self.esPoderValido(nuevoPoder)) {
            self.error("El poder innato debe estar entre 1 y 10, recibido: " + nuevoPoder)
        }
        poderInato = nuevoPoder
    }

    var property objetosMagicos = []

    method poderTotal() = objetosMagicos.sum{un=>un.poder(self) } * poderInato

    method desafiaA(enemigo){ 
        if(enemigo.esVencidoPor(self)){
            const energiaRobada = enemigo.energiaQuePierde()
            enemigo.pierdePorDerrota()
            self.ganaPuntos(energiaRobada)
        }
    }

    method ganaPuntos(energia) { 
        energiaMagica = energiaMagica + energia
    }

    method pierdePorDerrota()
    
    method esVencidoPor(atacante)
    
    method energiaQuePierde()

    method lider() = self
}

class Aprendis inherits Mago{

    override method esVencidoPor(atacante) = resistencia < atacante.poderTotal()

    override method energiaQuePierde() = energiaMagica / 2

    override method pierdePorDerrota() {
        energiaMagica = energiaMagica / 2
    }
}

class Veterano inherits Mago{

    override method esVencidoPor(atacante) = atacante.poderTotal() >= resistencia * 1.5

    override method energiaQuePierde() = energiaMagica / 4

    override method pierdePorDerrota() {
        energiaMagica = energiaMagica / 4
    }
}

class Inmortales inherits Mago{
    
    override method esVencidoPor(atacante) = false
    
    override method energiaQuePierde() = 0
    
    override method pierdePorDerrota() {
        // No pierde nada porque no puede ser vencido
    }
}

class ObjetoMagico{

    method poder(mago)
}

class Varita inherits ObjetoMagico{

    var property poderBase

    override method poder(mago) = if(mago.nombre().length().even()) poderBase*1.5 else poderBase
}

class Tunica inherits ObjetoMagico{

    method resistenciaMagicaDe(mago)= mago.resistencia()

    override method poder(mago) = self.resistenciaMagicaDe(mago) * 2
}

class TunicaEpica inherits Tunica{

    override method poder(mago) = super(mago) + 10
}

class Amuleto inherits ObjetoMagico{

    override method poder(mago) = 200 
}

class Ojota inherits ObjetoMagico{

    override method poder(mago) = mago.nombre().length() * 10 
}

class Gremio{
    
    var property miembros = []

    method initialize() { // para que haya almenos 2 magos
        if(miembros.size() < 2) {
            self.error("Un gremio debe tener al menos 2 miembros, recibidos: " + miembros.size())
        }
    }
    
    method lider() {
        const miembroMasPoderoso = miembros.max{un=>un.poderTotal()}
        return miembroMasPoderoso.lider()  // Si es gremio, devuelve su líder; si es mago, se devuelve a sí mismo
    }
    
    method poderTotal() = miembros.sum{un=>un.poderTotal()}

    method energiaMagica() = miembros.sum{un=>un.energiaMagica()}

    method desafiaA(entidadEnemiga) {
        if(entidadEnemiga.esVencidoPor(self)){
            const energiaRobada = entidadEnemiga.energiaQuePierde()
            entidadEnemiga.pierdePorDerrota()
            self.lider().ganaPuntos(energiaRobada)
        }
    }

    method resistenciaGremio() = miembros.sum{un=>un.resistencia()}
    
    method resistencia() = self.resistenciaGremio()  // Para que un gremio pueda ser miembro de otro gremio

    method esVencidoPor(enemigo) = enemigo.poderTotal() > (self.resistenciaGremio() + self.lider().resistencia())

    method energiaQuePierde() = self.energiaMagica()

    method pierdePorDerrota() {
        miembros.forEach{un=>un.pierdePorDerrota()}
    }
    
    method ganaPuntos(energia) {
        self.lider().ganaPuntos(energia)  // Delega al líder real (que siempre es un mago)
    }
}

    








