<h1 align="center">НИР - "ЦифроГид".</h1>

<p style="font-weight:bold">"ЦифроГид" - мобильное приложение с элементами дополненной реальности и распознавания объектов для идентифицирования памятников Сталинградской битвы в городе Волгоград.</p>

---
<h2 align="center">
Мобильное приложение "ЦифроГид" разработали студенты ВолгГТУ, факультета 
</h2>
<div style="display:block;">
<a href="https://github.com/VladislavGrom1"><img src="https://avatars.githubusercontent.com/u/108086934?v=4" alt="Kolyamba-mamba" width="50" height="50"> </a>
        <span >Ваганов Владислав - ИВТ-363</span>
        <span color="red">(Дизайн и карта)</span>
    
    
</div>
<div style="display:block;">
    <div style="display:inline-block; font-weight:bold; font-size:1.3rem;">
        <span>Васильев Иван - ИВТ-363</span>
        <p style="color:red">(Распознавание объектов)</p>
    </div>
    
        <a href="https://github.com/B-es"><img src="https://avatars.githubusercontent.com/u/104147126?v=4" alt="tankistqazwsx" width="50" height="50"> </a>
    
</div>
<div style="display:block;">
    <div style="display:inline-block; font-weight:bold; font-size:1.3rem;">
        <span>Маттиев Рустам - ИВТ-363</span>
        <p style="color:red">(Вёрстка и тестирование)</p>
    </div>
    <!--
        <a href="https://github.com/lizard222"><img src="https://avatars.githubusercontent.com/u/108584139?v=4" alt="tankistqazwsx" width="50" height="50"> </a>
    
</div>
<div style="display:block;">
    <div style="display:inline-block; font-weight:bold; font-size:1.3rem;">
        <span>Челядинов Дмитрий - ИВТ-363</span>
        <p style="color:red">(Дополненная реальность)</p>
    </div>
        
            <a href="https://github.com/Chilik78"><img src="https://avatars.githubusercontent.com/u/104494266?v=4" alt="tankistqazwsx" width="50" height="50"></a>
        
</div>

---

<div style="display:block; font-weight:bold; font-size:1.3rem;">
<span>Скоробогатченко Дмитрий Анатольевич</span>
<p style="color:red">(Научный руководитель проекта)</p>
</div>

---


### В мобильном приложении функционируют 3 модуля:
1) Режим сканирования для определения объекта в режиме реального времени
> _Режим сканирования включает в себя 4 различных модели на выбор для определения объекта/его ключевых точек._
2) Интерактивная карта "Яндекс-Карты"
> _В режиме интерактивной карты исходные координаты выставлены на высотный корпус ВолгГТУ. На данный момент функционирует только возможность пролистывания карты._
3) Режим дополненной реальности с отображением 3d-объектов в реальном времени
> _В режиме дополненной реальности в координатах пользователя генерируется 3d объект исторического фото._

---

### Для запуска приложения понадобится:
1) Установить [Flutter](https://docs.flutter.dev/get-started/install) последней версии
2) Установить [VSCode](https://code.visualstudio.com) или [Android Studio](https://developer.android.com/studio) с плагином Flutter
- Или создать эмулятор и запустить любым доступным способом из документации
- Или скомпилировать apk с помощью команды:
```bash
flutter build apk --release --no-tree-shake-icons --no-shrink --no-color -t lib/main.dart
```

### Установка приложения на Android смартфон
1) Скачайте APK-файл мобильного приложения на смартфон Android
2) Установите APK-файл через проводник
3) Запустите "ЦифроГид"

**_P.S Для запуска модуля дополненной реальности потребуется дополнительная установка AR-Google на смартфон. При этом AR-Google поддерживает ограниченный набор смартфонов._**


