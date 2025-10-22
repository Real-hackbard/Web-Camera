# Web-Camera:

</br>

![Compiler](https://github.com/user-attachments/assets/a916143d-3f1b-4e1f-b1e0-1067ef9e0401) &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: ![10 Seattle](https://github.com/user-attachments/assets/c70b7f21-688a-4239-87c9-9a03a8ff25ab) ![10 1 Berlin](https://github.com/user-attachments/assets/bdcd48fc-9f09-4830-b82e-d38c20492362) ![10 2 Tokyo](https://github.com/user-attachments/assets/5bdb9f86-7f44-4f7e-aed2-dd08de170bd5) ![10 3 Rio](https://github.com/user-attachments/assets/e7d09817-54b6-4d71-a373-22ee179cd49c)   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![10 4 Sydney](https://github.com/user-attachments/assets/e75342ca-1e24-4a7e-8fe3-ce22f307d881) ![11 Alexandria](https://github.com/user-attachments/assets/64f150d0-286a-4edd-acab-9f77f92d68ad) ![12 Athens](https://github.com/user-attachments/assets/59700807-6abf-4e6d-9439-5dc70fc0ceca)  
![Components](https://github.com/user-attachments/assets/d6a7a7a4-f10e-4df1-9c4f-b4a1a8db7f0e) : ![Direct3D9 pas](https://github.com/user-attachments/assets/e0575973-b986-4326-bef4-f7fb291cb349) ![VSample pas](https://github.com/user-attachments/assets/18afed17-1d72-46c4-87c2-8d3262cd8a2d)  
![Discription](https://github.com/user-attachments/assets/4a778202-1072-463a-bfa3-842226e300af) &nbsp;&nbsp;: ![Web Camera](https://github.com/user-attachments/assets/32bf202a-4a65-40f6-9fde-b26046c025ed)   
![Last Update](https://github.com/user-attachments/assets/e1d05f21-2a01-4ecf-94f3-b7bdff4d44dd) &nbsp;: ![102025](https://github.com/user-attachments/assets/62cea8cc-bd7d-49bd-b920-5590016735c0)  
![License](https://github.com/user-attachments/assets/ff71a38b-8813-4a79-8774-09a2f3893b48) &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: ![Freeware](https://github.com/user-attachments/assets/1fea2bbf-b296-4152-badd-e1cdae115c43)

</br>

### Quality Options:
* Brightness
* Contrast
* Hue
* Sharpness
* Saturation
* Gamma
* Color
* White Balance
* Blacklight
* Gain

### Video Options:
* Load DirectX
* Normal
* Inverted
* Grayscal
* Difference Map
* Highlighted Differences
* Surveilance
* Video Size

</br>

![Webcam Capture](https://github.com/user-attachments/assets/14a682c6-0664-4ddf-b165-69a390a7ee45)

</br>

Microsoft DirectX is a collection of application programming interfaces (APIs) for handling tasks related to multimedia, especially game programming and video, on Microsoft platforms. Originally, the names of these APIs all began with "Direct", such as [Direct3D](https://en.wikipedia.org/wiki/Direct3D), [DirectDraw](https://en.wikipedia.org/wiki/DirectDraw), [DirectMusic](https://en.wikipedia.org/wiki/DirectMusic), [DirectPlay](https://en.wikipedia.org/wiki/DirectPlay), [DirectSound](https://en.wikipedia.org/wiki/DirectSound), and so forth.

### DirectX Components in Project:
* Direct3D9
* DirectDraw
* DirectShow9
* DirectSound
* DXTypes

</br>

### DirectX Copyright (C):

```
|##############################################################################|
{*                                                                            *}
{*  Copyright (C) Microsoft Corporation.  All Rights Reserved.                *}
{*                                                                            *}
{*  Files:      d3d9types.h d3d9caps.h d3d9.h                                 *}
{*  Content:    Direct3D9 include files                                       *}
{*                                                                            *}
{*  DirectX 9.0 Delphi / FreePascal adaptation by Alexey Barkovoy             *}
{*  E-Mail: directx@clootie.ru                                                *}
{*                                                                            *}
{*  Latest version can be downloaded from:                                    *}
{*    http://clootie.ru                                                       *}
{*    http://sourceforge.net/projects/delphi-dx9sdk                           *}
{*                                                                            *}
|##############################################################################|
{*  $Id: Direct3D9.pas,v 1.13 2006/10/22 22:00:33 clootie Exp $ }
|##############################################################################|
{                                                                              }
{ Obtained through: Joint Endeavour of Delphi Innovators (Project JEDI)        }
{                                                                              }
{ The contents of this file are used with permission, subject to the Mozilla   }
{ Public License Version 1.1 (the "License"); you may not use this file except }
{ in compliance with the License. You may obtain a copy of the License at      }
{ http://www.mozilla.org/MPL/MPL-1.1.html                                      }
{                                                                              }
{ Software distributed under the License is distributed on an "AS IS" basis,   }
{ WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for }
{ the specific language governing rights and limitations under the License.    }
{                                                                              }
{ Alternatively, the contents of this file may be used under the terms of the  }
{ GNU Lesser General Public License (the  "LGPL License"), in which case the   }
{ provisions of the LGPL License are applicable instead of those above.        }
{ If you wish to allow use of your version of this file only under the terms   }
{ of the LGPL License and not to allow others to use your version of this file }
{ under the MPL, indicate your decision by deleting  the provisions above and  }
{ replace  them with the notice and other provisions required by the LGPL      }
{ License.  If you do not delete the provisions above, a recipient may use     }
{ your version of this file under either the MPL or the LGPL License.          }
{                                                                              }
{ For more information about the LGPL: http://www.gnu.org/copyleft/lesser.html }
{                                                                              }
|##############################################################################|

================================================================================

      |##################################################################|
      | Borland Delphi 4,5,6,7 API for Direct Show                       |
      | DirectX 9.0 Win 98, Me, 2000, XP, 7, 8, 8.1, 10, 11              |
      |                                                                  |
      | Portions created by Microsoft are                                |
      | Copyright (C) 1995-2002 Microsoft Corporation.                   |
      | All Rights Reserved.                                             |
      |                                                                  |
      | The original files are:                                          |
      |   comlite.h, errors.h, dv.h, strmif.h, mmstream.h, amstream.h,   |
      |   ddstream.h, austream.h, mpconfig.h, control.h, qnetwork.h,     |
      |   playlist.h, il21dec.h, amvideo.h, amaudio.h, vptype.h,         |
      |   vpconfig.h, vpnotify.h, mpegtype.h, dvdevcod.h, dvdmedia.h,    |
      |   bdatypes.h, activecf.h, vfwmsgs.h,(edevdefs.h, XPrtDefs.h),    |
      |   aviriff.h, evcode.h, uuids.h, ksuuids.h, DXVA.h,AMVA.h,        |
      |   videoacc.h, regbag.h, tuner.h, DXTrans.h, QEdit.h, mpeguids.h, |
      |   dshowasf.h, amparse.h, audevcod.h, atsmedia.h, MediaErr,       |
      |   MedParam.h, mediaobj.h, dmodshow.h, dmoreg.h, DMORt.h,         |
      |   dmoimpl.h, ks.h, ksproxy.h, ksmedia.h, dmksctrl.h, bdamedia.h, |
      |   BDATIF.idl, AMVPE.idl, Mixerocx.idl, Mpeg2Data.idl,            |
      |   Mpeg2Structs.idl, Mpeg2Bits.h, Mpeg2Error.h, EDevCtrl.h,       |
      |   sbe.idl, vmr9.idl, iwstdec.h                                   |
      |                                                                  |
      | The original Pascal code is: DirectShow9.pas,                    |
      |   released 01 Nov 2003.                                          |
      |                                                                  |
      | The initial developer of the Pascal code is Henri GOURVEST       |
      |   Email    : hgourvest@progdigy.com                              |
      |   WebSite  : http://www.progdigy.com                             |
      |                                                                  |
      | Portions created by Henri GOURVEST are                           |
      | Copyright (C) 2002 Henri GOURVEST.                               |
      |                                                                  |
      | Contributors: Ivo Steinmann                                      |
      |               Peter NEUMANN                                      |
      |               Alexey Barkovoy                                    |
      |               Wayne Sherman                                      |
      |               Peter J. Haas     <DSPack@pjh2.de>                 |
      |               Andriy Nevhasymyy <a.n@email.com>                  |
      |               Milenko Mitrovic  <dcoder@dsp-worx.de>             |
      |               Michael Andersen  <michael@mechdata.dk>            |
      |               Martin Offenwanger <coder@dsplayer.de              |
      |                                                                  |
      | Joint Endeavour of Delphi Innovators (Project JEDI)              |
      |                                                                  |
      | You may retrieve the latest version of this file here:           |
      |   http://www.progdigy.com                                        |
      |                                                                  |
      | The contents of this file are used with permission, subject to   |
      | the Mozilla Public License Version 1.1 (the "License"); you may  |
      | not use this file except in compliance with the License. You may |
      | obtain a copy of the License at                                  |
      | http://www.mozilla.org/MPL/MPL-1.1.html                          |
      |                                                                  |
      | Software distributed under the License is distributed on an      |
      | "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or   |
      | implied. See the License for the specific language governing     |
      | rights and limitations under the License.                        |
      |                                                                  |
      |******************************************************************|
