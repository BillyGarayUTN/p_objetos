// MAGOS //

class Mago{

    var property nombre
    var property resistenciaMagica
    var property energiaMagica
    var property reservaMagica
    var property objetosMagicos = []
    var property poderInnato  // van de 1a 10

    method initialize() {
        if(!(poderInnato<=10 && poderInnato>=1))
            throw new Exception(message = "El poder innato debe estar entre 1 y 10")
    }

    method poderTotal() = (objetosMagicos.sum{ un=> un.poder() }) * self.poderInnato()

    method desafiaA(enemigo) {
        if(self.venceA(enemigo))
            // El mago ganador obtiene la energía mágica del perdedor
            reservaMagica = reservaMagica + enemigo.energiaMagica()
            enemigo.loQuepierdePorDerrota()
    }


    method venceA(enemigo) = enemigo.esVencidoPor(self)

    method esVencidoPor(enemigo) 

    method pierdeMitadEnergiaMagica() { energiaMagica = energiaMagica / 2 } 

    method loQuepierdePorDerrota(){}

    // Método polimórfico para obtener el líder real (en magos es ellos mismos)
    method liderReal() = self
}

class Aprendiz inherits Mago{

    override method esVencidoPor(enemigo) = enemigo.energiaMagica() > self.energiaMagica()

    override method loQuepierdePorDerrota() { self.pierdeMitadEnergiaMagica() }

}

class Vetenaro inherits Mago{

    override method esVencidoPor(enemigo) = self.energiaMagica() * 1.5 < enemigo.poderTotal() 

    override method loQuepierdePorDerrota()  { resistenciaMagica = resistenciaMagica / 4 }
}

class Inmortales inherits Mago{

    override method esVencidoPor(enemigo) = false 

    override method loQuepierdePorDerrota() {} // Los inmortales no pierden nada

}

// OBJETOS MAGICOS //

class Varitas{
    const poderBase

    method poder(mago) = if(mago.nombre().length().even()) poderBase * 1.5 else poderBase
}

class Tunica{
    const poderBase

    method poder(mago) = mago.resistenciaMagica() *2 + poderBase
}

class TunicaEpica inherits Tunica{
    override method poder(mago) = super(mago) + 10 
} 

class Amuleto{

    method poder(mago) = 200
}

object ojota{

    method poder(mago) = mago.nombre().length() * 10 
}

class Gremio{

    var property miembros = []

    // Inicialización que valida al menos 2 miembros
    method initialize() {
        if (miembros.size() < 2) {
            throw new Exception(message = "Un gremio debe tener al menos 2 miembros")
        }
    }

    method agregarMiembro(miembro) {
        miembros.add(miembro)
    }

    method poderTotal() = miembros.sum{ un => un.poderTotal() }
    
    method reservaDelGremio() = miembros.sum{ un => un.reservaMagica() }

    method lider() {
        const miembroMasPoderoso = miembros.max{ un => un.poderTotal() }
        return miembroMasPoderoso.liderReal()
    }

    // Método polimórfico para obtener el líder real
    // Si es un gremio, debe buscar recursivamente su líder
    method liderReal() = self.lider()

    // Método para que un gremio desafíe a otro mago o gremio
    method desafiaA(enemigo) {
        if(self.venceA(enemigo)) {
            // Los puntos van a la reserva del líder del gremio
            self.lider().reservaMagica(self.lider().reservaMagica() + enemigo.energiaMagica())
            enemigo.loQuepierdePorDerrota()
        }
    }

    // Para vencer a un gremio: poder total del atacante > resistencia total + resistencia del líder
    method venceA(enemigo) = self.poderTotal() > enemigo.resistenciaTotalConLider()

    // Resistencia total del gremio más la del líder (que cuenta doble)
    method resistenciaTotalConLider() = self.resistenciaTotal() + self.lider().resistenciaMagica()
    
    // Resistencia total de todos los miembros
    method resistenciaTotal() = miembros.sum{ un => un.resistenciaMagica() }

    // Cuando un gremio es desafiado por un mago individual
    method esVencidoPor(enemigo) = enemigo.poderTotal() > self.resistenciaTotalConLider()
    
    // Lo que pierde el gremio por derrota
    method loQuepierdePorDerrota() {
        // Cada miembro del gremio pierde por la derrota
        miembros.forEach{ miembro => miembro.loQuepierdePorDerrota() }
    }

    // Energía mágica total del gremio (para cuando es vencido)
    method energiaMagica() = miembros.sum{ un => un.energiaMagica() }

}

// EJEMPLO DE SUB-GREMIOS:
// 
// Supongamos:
// - mago1 (poder: 100), mago2 (poder: 200)
// - mago3 (poder: 300), mago4 (poder: 150)
// 
// subGremio1 = new Gremio(miembros = [mago1, mago2])  // líder: mago2
// subGremio2 = new Gremio(miembros = [mago3, mago4])  // líder: mago3
// 
// gremioCompuesto = new Gremio(miembros = [subGremio1, subGremio2])
// 
// gremioCompuesto.lider() retornará mago3 (el más poderoso de todos)
// porque:
// 1. subGremio2 tiene mayor poder total que subGremio1
// 2. liderReal() de subGremio2 retorna su líder (mago3)
//
// ¡El polimorfismo permite que gremios y magos se comporten igual!

