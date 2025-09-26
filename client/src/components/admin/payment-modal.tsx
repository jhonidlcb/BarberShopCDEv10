import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { useCurrency } from '@/hooks/use-currency';
import { useAdminApi } from '@/hooks/use-admin-api';

interface PaymentModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: (amount: number, currency: string, employeeId?: string) => void;
  customerName: string;
  serviceType: string;
}

export function PaymentModal({ isOpen, onClose, onConfirm, customerName, serviceType }: PaymentModalProps) {
  const [amount, setAmount] = useState('');
  const [selectedCurrency, setSelectedCurrency] = useState('USD');
  const [selectedEmployee, setSelectedEmployee] = useState('');
  const { currencies, formatPrice, getCurrencySymbol } = useCurrency();
  const api = useAdminApi();

  const { data: employees } = useQuery({
    queryKey: ['/api/admin/employees'],
    queryFn: () => api.get('/api/admin/employees'),
    enabled: isOpen,
  });

  const handleConfirm = () => {
    const numAmount = parseFloat(amount);
    if (isNaN(numAmount) || numAmount <= 0) {
      return;
    }
    onConfirm(numAmount, selectedCurrency, selectedEmployee || undefined);
    setAmount('');
    setSelectedCurrency('USD');
    setSelectedEmployee('');
    onClose();
  };

  const handleClose = () => {
    setAmount('');
    setSelectedCurrency('USD');
    setSelectedEmployee('');
    onClose();
  };

  return (
    <Dialog open={isOpen} onOpenChange={handleClose}>
      <DialogContent className="sm:max-w-[425px] bg-slate-800 text-white border-slate-700">
        <DialogHeader>
          <DialogTitle className="text-green-400">💰 Registrar Pago</DialogTitle>
          <DialogDescription className="text-slate-300">
            <div className="space-y-2">
              <div><strong>Cliente:</strong> {customerName}</div>
              <div><strong>Servicio:</strong> {serviceType}</div>
              <div className="bg-blue-500/10 p-3 rounded-lg border border-blue-500/20 mt-3">
                <p className="text-blue-300 font-medium mb-2">📋 Instrucciones importantes:</p>
                <div className="text-sm space-y-1">
                  <p><strong>💵 USD/BRL:</strong> Usa punto (.) para decimales. Ej: 25.50</p>
                  <p><strong>₲ Guaraníes:</strong> Solo números enteros, sin puntos ni comas. Ej: 180000</p>
                  <p><strong>⚠️ Importante:</strong> Ingresa el monto exacto que cobró al cliente</p>
                </div>
              </div>
            </div>
          </DialogDescription>
        </DialogHeader>
        <form onSubmit={(e) => { e.preventDefault(); handleConfirm(); }} className="space-y-4">
          <div className="space-y-4">
            <div>
              <Label className="text-white">Cliente: {customerName}</Label>
            </div>
            <div>
              <Label className="text-white">Servicio: {serviceType}</Label>
            </div>

            <div>
              <Label htmlFor="employee" className="text-white">Empleado que Atendió</Label>
              <Select value={selectedEmployee} onValueChange={setSelectedEmployee}>
                <SelectTrigger className="bg-slate-700 border-slate-600 text-white">
                  <SelectValue placeholder="Seleccionar empleado..." />
                </SelectTrigger>
                <SelectContent className="bg-slate-700 border-slate-600">
                  <SelectItem value="" className="text-white hover:bg-slate-600">
                    Sin asignar
                  </SelectItem>
                  {employees?.filter((emp: any) => emp.active && emp.canLogin).map((employee: any) => (
                    <SelectItem
                      key={employee.id}
                      value={employee.id}
                      className="text-white hover:bg-slate-600"
                    >
                      {employee.staffMember?.name || employee.username}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div>
              <Label htmlFor="currency" className="text-white">Moneda de Pago</Label>
              <Select value={selectedCurrency} onValueChange={setSelectedCurrency}>
                <SelectTrigger className="bg-slate-700 border-slate-600 text-white">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent className="bg-slate-700 border-slate-600">
                  {currencies.map((currency) => (
                    <SelectItem
                      key={currency.currencyCode}
                      value={currency.currencyCode}
                      className="text-white hover:bg-slate-600"
                    >
                      {currency.currencySymbol} {currency.currencyName}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="amount" className="text-white">Monto Cobrado</Label>
            <Input
              id="amount"
              type="number"
              step={selectedCurrency === 'PYG' ? '1' : '0.01'}
              min="0"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              placeholder={
                selectedCurrency === 'USD' ? '25.50' :
                selectedCurrency === 'BRL' ? '130.75' :
                selectedCurrency === 'PYG' ? '180000' : '0.00'
              }
              className="pl-8 bg-slate-700 border-slate-600 text-white"
              required
              autoFocus
            />
            <p className="text-xs text-slate-400 mt-1">
              <strong>Configuración de precios:</strong><br/>
              • USD: Precio base configurado en el servicio<br/>
              • BRL: Se multiplica por el valor del Real configurado<br/>
              • PYG: Se multiplica por el valor del Guaraní configurado<br/>
              <em>Los precios se calculan automáticamente según la configuración de monedas.</em>
            </p>

            {/* Explicaciones específicas por moneda */}
            {selectedCurrency === 'USD' && (
              <div className="bg-green-500/10 p-3 rounded-lg border border-green-500/20">
                <p className="text-green-300 text-sm font-medium mb-1">💵 Dólares Americanos (USD)</p>
                <p className="text-xs text-green-200">
                  ✅ Usa punto (.) para decimales: <span className="font-mono bg-black/20 px-1 rounded">25.50</span><br/>
                  ❌ No uses comas: <span className="font-mono bg-black/20 px-1 rounded line-through">25,50</span>
                </p>
              </div>
            )}

            {selectedCurrency === 'BRL' && (
              <div className="bg-blue-500/10 p-3 rounded-lg border border-blue-500/20">
                <p className="text-blue-300 text-sm font-medium mb-1">🇧🇷 Reales Brasileños (BRL)</p>
                <p className="text-xs text-blue-200">
                  ✅ Usa punto (.) para decimales: <span className="font-mono bg-black/20 px-1 rounded">130.75</span><br/>
                  ❌ No uses comas: <span className="font-mono bg-black/20 px-1 rounded line-through">130,75</span><br/>
                  💡 Ejemplo: R$ 130.75 = ciento treinta reales con setenta y cinco centavos
                </p>
              </div>
            )}

            {selectedCurrency === 'PYG' && (
              <div className="bg-orange-500/10 p-3 rounded-lg border border-orange-500/20">
                <p className="text-orange-300 text-sm font-medium mb-1">🇵🇾 Guaraníes Paraguayos (PYG)</p>
                <p className="text-xs text-orange-200">
                  ✅ Solo números enteros (sin decimales): <span className="font-mono bg-black/20 px-1 rounded">180000</span><br/>
                  ❌ No uses puntos ni comas: <span className="font-mono bg-black/20 px-1 rounded line-through">180.000</span> o <span className="font-mono bg-black/20 px-1 rounded line-through">180,000</span><br/>
                  💡 Ejemplo: ₲ 180000 = ciento ochenta mil guaraníes
                </p>
              </div>
            )}
          </div>

          <DialogFooter className="gap-2 pt-4">
            <Button
              type="button"
              variant="outline"
              onClick={handleClose}
              className="border-slate-600 text-slate-300 hover:bg-slate-700"
            >
              Cancelar
            </Button>
            <Button
              type="submit"
              className="bg-green-500 hover:bg-green-600"
              disabled={!amount || parseFloat(amount) <= 0}
            >
              {!amount || parseFloat(amount) <= 0 ? (
                'Ingresa el monto'
              ) : (
                `Registrar ${getCurrencySymbol(selectedCurrency as any)}${amount} ${selectedCurrency}`
              )}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}