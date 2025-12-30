import '@testing-library/jest-dom'
import { render, screen } from '@testing-library/react'
import Home from '../page'

describe('Página de inicio', () => {
    it('renderiza un encabezado con "Hola Damián!"', () => {
        render(<Home />)

        const heading = screen.getByRole('heading', { level: 1 })

        expect(heading).toBeInTheDocument()
        expect(heading).toHaveTextContent('Hola Damián!')
    })

    it('contiene el mensaje de bienvenida', () => {
        render(<Home />)
        const paragraph = screen.getByText(/Bienvenido a tu primer proyecto usando Antigravity/i)
        expect(paragraph).toBeInTheDocument()
    })
})
