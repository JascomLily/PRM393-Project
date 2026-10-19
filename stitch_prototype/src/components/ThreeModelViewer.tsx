import React, { useEffect, useRef, useState, useCallback } from 'react';
import * as THREE from 'three';

interface ThreeModelViewerProps {
  currentStep: number;
  explodedAmount?: number;
  isPlaying?: boolean;
  onTogglePlay?: () => void;
  speed?: number;
  onOpenAR?: () => void;
  onPinClick?: (pinName: string) => void;
}

export const ThreeModelViewer: React.FC<ThreeModelViewerProps> = ({
  currentStep,
  explodedAmount = 0.35,
  isPlaying = false,
  onTogglePlay,
  speed = 1,
  onOpenAR,
  onPinClick,
}) => {
  const containerRef = useRef<HTMLDivElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);

  // Hotspot pin 2D projection coordinates
  const [pin1Pos, setPin1Pos] = useState<{ x: number; y: number; visible: boolean }>({ x: 0, y: 0, visible: false });
  const [pin2Pos, setPin2Pos] = useState<{ x: number; y: number; visible: boolean }>({ x: 0, y: 0, visible: false });
  const [activeTooltip, setActiveTooltip] = useState<string | null>(null);

  const sceneRef = useRef<THREE.Scene | null>(null);
  const cameraRef = useRef<THREE.PerspectiveCamera | null>(null);
  const rendererRef = useRef<THREE.WebGLRenderer | null>(null);
  const modelGroupRef = useRef<THREE.Group | null>(null);

  // Parts references for exploded animation
  const topPartRef = useRef<THREE.Mesh | null>(null);
  const legsRef = useRef<THREE.Mesh[]>([]);
  const screwsRef = useRef<THREE.Mesh[]>([]);
  const apronsRef = useRef<THREE.Mesh[]>([]);

  // Orbit drag tracking
  const isDraggingRef = useRef(false);
  const previousMousePositionRef = useRef({ x: 0, y: 0 });
  const rotationTargetRef = useRef({ x: 0.3, y: 0.6 });
  const zoomLevelRef = useRef(4.8);
  const animTimeRef = useRef(0);
  const currentExplodeRef = useRef(explodedAmount);

  // Initialize Three.js scene
  useEffect(() => {
    if (!canvasRef.current || !containerRef.current) return;

    const width = containerRef.current.clientWidth;
    const height = containerRef.current.clientHeight;

    const scene = new THREE.Scene();
    sceneRef.current = scene;

    const camera = new THREE.PerspectiveCamera(38, width / height, 0.1, 100);
    camera.position.set(0, 2.2, zoomLevelRef.current);
    cameraRef.current = camera;

    let renderer: THREE.WebGLRenderer;
    try {
      renderer = new THREE.WebGLRenderer({
        canvas: canvasRef.current,
        antialias: true,
        alpha: true,
        powerPreference: 'high-performance',
      });
      renderer.setSize(width, height);
      renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
      renderer.shadowMap.enabled = true;
      renderer.shadowMap.type = THREE.PCFSoftShadowMap;
      rendererRef.current = renderer;
    } catch {
      return;
    }

    // Lighting (Warm Scandinavian daylight)
    const ambientLight = new THREE.AmbientLight(0xfff6ea, 1.2);
    scene.add(ambientLight);

    const dirLight = new THREE.DirectionalLight(0xffffff, 1.6);
    dirLight.position.set(4, 7, 5);
    dirLight.castShadow = true;
    dirLight.shadow.mapSize.width = 1024;
    dirLight.shadow.mapSize.height = 1024;
    dirLight.shadow.camera.near = 0.5;
    dirLight.shadow.camera.far = 15;
    dirLight.shadow.camera.left = -3;
    dirLight.shadow.camera.right = 3;
    dirLight.shadow.camera.top = 3;
    dirLight.shadow.camera.bottom = -3;
    dirLight.shadow.bias = -0.0005;
    scene.add(dirLight);

    const rimLight = new THREE.DirectionalLight(0xcde1d5, 0.8);
    rimLight.position.set(-4, 3, -3);
    scene.add(rimLight);

    // Subtle floor shadow plane
    const shadowGeo = new THREE.PlaneGeometry(8, 8);
    const shadowMat = new THREE.ShadowMaterial({ opacity: 0.14 });
    const shadowPlane = new THREE.Mesh(shadowGeo, shadowMat);
    shadowPlane.rotation.x = -Math.PI / 2;
    shadowPlane.position.y = -0.85;
    shadowPlane.receiveShadow = true;
    scene.add(shadowPlane);

    // Root model group
    const modelGroup = new THREE.Group();
    scene.add(modelGroup);
    modelGroupRef.current = modelGroup;

    // Materials: Realistic Scandinavian Oak & Brushed Nickel
    const oakWoodMat = new THREE.MeshStandardMaterial({
      color: 0xdfb482,
      roughness: 0.45,
      metalness: 0.05,
    });
    const darkOakMat = new THREE.MeshStandardMaterial({
      color: 0xb58853,
      roughness: 0.55,
      metalness: 0.05,
    });
    const metalMat = new THREE.MeshStandardMaterial({
      color: 0xa8b2bc,
      roughness: 0.25,
      metalness: 0.85,
    });
    const highlightMat = new THREE.MeshStandardMaterial({
      color: 0xfec38d,
      roughness: 0.3,
      metalness: 0.1,
      emissive: 0x805528,
      emissiveIntensity: 0.2,
    });

    // 1. Table Top
    const topGeo = new THREE.BoxGeometry(2.4, 0.09, 1.3);
    const topMesh = new THREE.Mesh(topGeo, oakWoodMat);
    topMesh.position.y = 0.75;
    topMesh.castShadow = true;
    topMesh.receiveShadow = true;
    modelGroup.add(topMesh);
    topPartRef.current = topMesh;

    // Table Aprons (Under-frame)
    const aprons: THREE.Mesh[] = [];
    const apronLongGeo = new THREE.BoxGeometry(2.0, 0.1, 0.04);
    const apronShortGeo = new THREE.BoxGeometry(0.04, 0.1, 0.95);

    const frontApron = new THREE.Mesh(apronLongGeo, darkOakMat);
    frontApron.position.set(0, 0.65, 0.48);
    frontApron.castShadow = true;
    modelGroup.add(frontApron);
    aprons.push(frontApron);

    const backApron = new THREE.Mesh(apronLongGeo, darkOakMat);
    backApron.position.set(0, 0.65, -0.48);
    backApron.castShadow = true;
    modelGroup.add(backApron);
    aprons.push(backApron);

    const leftApron = new THREE.Mesh(apronShortGeo, darkOakMat);
    leftApron.position.set(-1.0, 0.65, 0);
    leftApron.castShadow = true;
    modelGroup.add(leftApron);
    aprons.push(leftApron);

    const rightApron = new THREE.Mesh(apronShortGeo, darkOakMat);
    rightApron.position.set(1.0, 0.65, 0);
    rightApron.castShadow = true;
    modelGroup.add(rightApron);
    aprons.push(rightApron);
    apronsRef.current = aprons;

    // 2. 4 Tapered Legs (CylinderGeometry with slightly angled splay)
    const legs: THREE.Mesh[] = [];
    const legPositions = [
      { x: -0.92, z: 0.44, rotZ: 0.06, rotX: 0.04, isFront: true },
      { x: 0.92, z: 0.44, rotZ: -0.06, rotX: 0.04, isFront: true },
      { x: -0.92, z: -0.44, rotZ: 0.06, rotX: -0.04, isFront: false },
      { x: 0.92, z: -0.44, rotZ: -0.06, rotX: -0.04, isFront: false },
    ];

    legPositions.forEach((pos) => {
      const legGeo = new THREE.CylinderGeometry(0.04, 0.024, 1.45, 16);
      const legMesh = new THREE.Mesh(legGeo, pos.isFront && currentStep === 3 ? highlightMat : oakWoodMat);
      legMesh.position.set(pos.x, -0.05, pos.z);
      legMesh.rotation.set(pos.rotX, 0, pos.rotZ);
      legMesh.castShadow = true;
      modelGroup.add(legMesh);
      legs.push(legMesh);
    });
    legsRef.current = legs;

    // 3. Cam Lock Screws & Joinery dowels
    const screws: THREE.Mesh[] = [];
    const screwPositions = [
      { x: -0.88, y: 0.67, z: 0.42 },
      { x: 0.88, y: 0.67, z: 0.42 },
      { x: -0.88, y: 0.67, z: -0.42 },
      { x: 0.88, y: 0.67, z: -0.42 },
    ];
    screwPositions.forEach((pos) => {
      const screwGeo = new THREE.CylinderGeometry(0.022, 0.015, 0.12, 12);
      const screwMesh = new THREE.Mesh(screwGeo, metalMat);
      screwMesh.position.set(pos.x, pos.y, pos.z);
      screwMesh.castShadow = true;
      modelGroup.add(screwMesh);
      screws.push(screwMesh);
    });
    screwsRef.current = screws;

    // Render loop
    let animFrameId: number;
    const animate = () => {
      animFrameId = requestAnimationFrame(animate);

      if (!modelGroupRef.current || !cameraRef.current || !rendererRef.current) return;

      // Smooth rotation toward drag target
      modelGroupRef.current.rotation.y += (rotationTargetRef.current.y - modelGroupRef.current.rotation.y) * 0.1;
      modelGroupRef.current.rotation.x += (rotationTargetRef.current.x - modelGroupRef.current.rotation.x) * 0.1;

      // Handle animated play explosion pulsing
      if (isPlaying) {
        animTimeRef.current += 0.025 * speed;
        currentExplodeRef.current = 0.2 + 0.3 * Math.abs(Math.sin(animTimeRef.current));
      } else {
        currentExplodeRef.current += (explodedAmount - currentExplodeRef.current) * 0.1;
      }

      const exp = currentExplodeRef.current;

      // Displace tabletop upward
      if (topPartRef.current) {
        topPartRef.current.position.y = 0.75 + exp * 0.65;
      }

      // Displace aprons slightly outward
      if (apronsRef.current.length === 4) {
        apronsRef.current[0].position.z = 0.48 + exp * 0.25; // front
        apronsRef.current[1].position.z = -0.48 - exp * 0.25; // back
        apronsRef.current[2].position.x = -1.0 - exp * 0.25; // left
        apronsRef.current[3].position.x = 1.0 + exp * 0.25; // right
      }

      // Displace legs downward and outward
      legsRef.current.forEach((leg, idx) => {
        const signX = idx % 2 === 0 ? -1 : 1;
        const signZ = idx < 2 ? 1 : -1;
        leg.position.y = -0.05 - exp * 0.45;
        leg.position.x = signX * (0.92 + exp * 0.35);
        leg.position.z = signZ * (0.44 + exp * 0.25);
      });

      // Displace screws upward
      screwsRef.current.forEach((screw, idx) => {
        const signX = idx % 2 === 0 ? -1 : 1;
        const signZ = idx < 2 ? 1 : -1;
        screw.position.y = 0.67 + exp * 0.4;
        screw.position.x = signX * (0.88 + exp * 0.3);
        screw.position.z = signZ * (0.42 + exp * 0.2);
      });

      // Smooth zoom
      cameraRef.current.position.z += (zoomLevelRef.current - cameraRef.current.position.z) * 0.1;

      // Project 3D Hotspot Pin 1 (Front Left Joint)
      const pin1Pos3D = new THREE.Vector3(-0.92, 0.62 + exp * 0.15, 0.44);
      pin1Pos3D.applyMatrix4(modelGroupRef.current.matrixWorld);
      pin1Pos3D.project(cameraRef.current);
      const x1 = ((pin1Pos3D.x + 1) * width) / 2;
      const y1 = ((-pin1Pos3D.y + 1) * height) / 2;
      setPin1Pos({ x: x1, y: y1, visible: pin1Pos3D.z < 1 });

      // Project 3D Hotspot Pin 2 (Cam Lock Screw)
      const pin2Pos3D = new THREE.Vector3(0.88, 0.67 + exp * 0.4, 0.42);
      pin2Pos3D.applyMatrix4(modelGroupRef.current.matrixWorld);
      pin2Pos3D.project(cameraRef.current);
      const x2 = ((pin2Pos3D.x + 1) * width) / 2;
      const y2 = ((-pin2Pos3D.y + 1) * height) / 2;
      setPin2Pos({ x: x2, y: y2, visible: pin2Pos3D.z < 1 });

      rendererRef.current.render(scene, cameraRef.current);
    };

    animate();

    const handleResize = () => {
      if (!containerRef.current || !rendererRef.current || !cameraRef.current) return;
      const newW = containerRef.current.clientWidth;
      const newH = containerRef.current.clientHeight;
      cameraRef.current.aspect = newW / newH;
      cameraRef.current.updateProjectionMatrix();
      rendererRef.current.setSize(newW, newH);
    };

    window.addEventListener('resize', handleResize);

    return () => {
      cancelAnimationFrame(animFrameId);
      window.removeEventListener('resize', handleResize);
      renderer.dispose();
    };
  }, [currentStep, isPlaying, speed, explodedAmount]);

  // Touch and Mouse drag gestures
  const handlePointerDown = (e: React.PointerEvent) => {
    isDraggingRef.current = true;
    previousMousePositionRef.current = { x: e.clientX, y: e.clientY };
    (e.target as HTMLElement).setPointerCapture?.(e.pointerId);
  };

  const handlePointerMove = (e: React.PointerEvent) => {
    if (!isDraggingRef.current) return;
    const deltaX = e.clientX - previousMousePositionRef.current.x;
    const deltaY = e.clientY - previousMousePositionRef.current.y;

    rotationTargetRef.current = {
      x: Math.max(-0.6, Math.min(1.0, rotationTargetRef.current.x + deltaY * 0.006)),
      y: rotationTargetRef.current.y + deltaX * 0.008,
    };

    previousMousePositionRef.current = { x: e.clientX, y: e.clientY };
  };

  const handlePointerUp = () => {
    isDraggingRef.current = false;
  };

  // Zoom controls
  const handleZoom = (delta: number) => {
    zoomLevelRef.current = Math.max(2.8, Math.min(7.5, zoomLevelRef.current + delta));
  };

  const handleResetView = () => {
    rotationTargetRef.current = { x: 0.3, y: 0.6 };
    zoomLevelRef.current = 4.8;
  };

  const speeds = [1, 1.5, 2, 0.5];
  const [speedIdx, setSpeedIdx] = useState(0);

  const cycleSpeed = () => {
    const nextIdx = (speedIdx + 1) % speeds.length;
    setSpeedIdx(nextIdx);
  };

  return (
    <div
      ref={containerRef}
      className="relative w-full aspect-[4/3] rounded-2xl overflow-hidden bg-gradient-to-b from-[#eef2f8] via-[#e6ebf5] to-[#dee5f2] shadow-md select-none touch-none group"
      onPointerDown={handlePointerDown}
      onPointerMove={handlePointerMove}
      onPointerUp={handlePointerUp}
      onPointerCancel={handlePointerUp}
    >
      <canvas ref={canvasRef} className="w-full h-full block cursor-grab active:cursor-grabbing" />

      {/* Grid Floor Overlay for Architectural Feel */}
      <div className="absolute inset-0 bg-[radial-gradient(#2d5a46_1px,transparent_1px)] [background-size:24px_24px] opacity-10 pointer-events-none" />

      {/* 3D Axis Gizmo Indicator (Top Right) */}
      <div className="absolute top-3 right-3 p-2 rounded-xl bg-white/90 backdrop-blur-md shadow-sm flex flex-col items-center pointer-events-auto border border-black/5">
        <svg className="w-8 h-8" viewBox="0 0 40 40" fill="none">
          <circle cx="20" cy="20" r="17" stroke="#c0c9c2" strokeWidth="1.5" strokeDasharray="2 2" />
          <line x1="20" y1="20" x2="20" y2="7" stroke="#2D5A46" strokeWidth="2.5" strokeLinecap="round" />
          <circle cx="20" cy="6" r="2.5" fill="#2D5A46" />
          <text x="23" y="10" fill="#2D5A46" className="text-[8px] font-bold">Y</text>
          <line x1="20" y1="20" x2="31" y2="27" stroke="#C28E5C" strokeWidth="2.5" strokeLinecap="round" />
          <circle cx="32" cy="28" r="2.5" fill="#C28E5C" />
          <text x="31" y="24" fill="#C28E5C" className="text-[8px] font-bold">X</text>
          <line x1="20" y1="20" x2="9" y2="26" stroke="#414944" strokeWidth="2.5" strokeLinecap="round" />
          <circle cx="8" cy="27" r="2.5" fill="#414944" />
          <text x="5" y="23" fill="#414944" className="text-[8px] font-bold">Z</text>
        </svg>
        <span className="text-[9px] text-[#414944] font-semibold mt-0.5 tracking-wider">360° 3D</span>
      </div>

      {/* Top Left: Joint Status Badge */}
      <div className="absolute top-3 left-3 flex flex-col gap-1.5 pointer-events-none">
        <div className="px-2.5 py-1 rounded-full bg-white/95 backdrop-blur-md shadow-sm border border-black/5 flex items-center gap-1.5">
          <span className="relative flex h-2 w-2">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[#805528] opacity-75"></span>
            <span className="relative inline-flex rounded-full h-2 w-2 bg-[#805528]"></span>
          </span>
          <span className="text-xs font-semibold text-[#161b28]">Khớp nối A-12</span>
        </div>
      </div>

      {/* Interactive 3D Hotspot 1 (Front Joint) */}
      {pin1Pos.visible && pin1Pos.x > 10 && pin1Pos.y > 10 && (
        <div
          style={{ left: `${pin1Pos.x}px`, top: `${pin1Pos.y}px` }}
          className="absolute -translate-x-1/2 -translate-y-1/2 pointer-events-auto z-20"
        >
          <button
            onClick={() => {
              setActiveTooltip(activeTooltip === 'joint' ? null : 'joint');
              onPinClick?.('Khớp mộng chân A-12');
            }}
            className="w-7 h-7 rounded-full bg-[#fec38d] text-[#794f23] shadow-md flex items-center justify-center transition-transform hover:scale-110 active:scale-95 border border-white"
            title="Xem vị trí khớp mộng A-12"
          >
            <span className="material-symbols-outlined text-[16px]">build</span>
          </button>
          {activeTooltip === 'joint' && (
            <div className="absolute left-8 top-1/2 -translate-y-1/2 px-2.5 py-1.5 rounded-lg bg-[#2b303e] text-white text-xs whitespace-nowrap shadow-xl z-30 animate-fadeIn">
              Lắp chốt ốc cam 90°
            </div>
          )}
        </div>
      )}

      {/* Interactive 3D Hotspot 2 (Screw Connector) */}
      {pin2Pos.visible && pin2Pos.x > 10 && pin2Pos.y > 10 && (
        <div
          style={{ left: `${pin2Pos.x}px`, top: `${pin2Pos.y}px` }}
          className="absolute -translate-x-1/2 -translate-y-1/2 pointer-events-auto z-20"
        >
          <button
            onClick={() => {
              setActiveTooltip(activeTooltip === 'screw' ? null : 'screw');
              onPinClick?.('Ốc khóa Cam Lock');
            }}
            className="w-6 h-6 rounded-full bg-white/95 text-[#2d5a46] shadow-md flex items-center justify-center transition-transform hover:scale-110 active:scale-95 animate-bounce border border-[#2d5a46]/20"
            title="Ốc siết Cam Lock"
          >
            <span className="material-symbols-outlined text-[14px]">touch_app</span>
          </button>
          {activeTooltip === 'screw' && (
            <div className="absolute right-8 top-1/2 -translate-y-1/2 px-2.5 py-1.5 rounded-lg bg-[#2b303e] text-white text-xs whitespace-nowrap shadow-xl z-30 animate-fadeIn">
              Chốt Cam M6x35 (#SC-04)
            </div>
          )}
        </div>
      )}

      {/* 360 Rotation Guidance Pill (Bottom Center) */}
      <div className="absolute bottom-3 left-1/2 transform -translate-x-1/2 px-3 py-1.5 rounded-full bg-white/90 backdrop-blur-md shadow-md border border-black/5 flex items-center gap-2 pointer-events-none">
        <span className="material-symbols-outlined text-[#805528] text-[15px] animate-spin" style={{ animationDuration: '6s' }}>
          sync
        </span>
        <span className="text-xs text-[#161b28] font-medium whitespace-nowrap">Chạm & xoay 360° để xem góc khuất</span>
      </div>

      {/* Floating View Controls (Bottom Left) */}
      <div className="absolute left-3 bottom-3 flex items-center gap-1 p-1 rounded-xl bg-white/90 backdrop-blur-md shadow-md border border-black/5 z-10">
        <button
          onClick={(e) => {
            e.stopPropagation();
            handleZoom(-0.6);
          }}
          className="w-7 h-7 rounded-lg flex items-center justify-center text-[#161b28] hover:bg-black/5 active:scale-95 transition-all"
          title="Phóng to"
        >
          <span className="material-symbols-outlined text-[17px]">zoom_in</span>
        </button>
        <button
          onClick={(e) => {
            e.stopPropagation();
            handleZoom(0.6);
          }}
          className="w-7 h-7 rounded-lg flex items-center justify-center text-[#161b28] hover:bg-black/5 active:scale-95 transition-all"
          title="Thu nhỏ"
        >
          <span className="material-symbols-outlined text-[17px]">zoom_out</span>
        </button>
        <button
          onClick={(e) => {
            e.stopPropagation();
            handleResetView();
          }}
          className="w-7 h-7 rounded-lg flex items-center justify-center text-[#161b28] hover:bg-black/5 active:scale-95 transition-all"
          title="Đặt lại góc nhìn"
        >
          <span className="material-symbols-outlined text-[17px]">center_focus_strong</span>
        </button>
      </div>

      {/* Floating Animation & AR Controls (Bottom Right) */}
      <div className="absolute right-3 bottom-3 flex items-center gap-1.5 p-1 rounded-xl bg-white/90 backdrop-blur-md shadow-md border border-black/5 z-10">
        <button
          onClick={(e) => {
            e.stopPropagation();
            onTogglePlay?.();
          }}
          className="w-8 h-8 rounded-lg bg-[#2d5a46] text-white flex items-center justify-center transition-transform active:scale-95 shadow-sm"
          title={isPlaying ? 'Tạm dừng bóc tách' : 'Phát hoạt họa bóc tách'}
        >
          <span className="material-symbols-outlined text-[18px]">
            {isPlaying ? 'pause' : 'play_arrow'}
          </span>
        </button>
        <button
          onClick={(e) => {
            e.stopPropagation();
            cycleSpeed();
          }}
          className="px-2 h-8 rounded-lg bg-[#e9edff] text-[#161b28] text-[11px] font-bold flex items-center justify-center hover:bg-[#dee2f4] transition-colors"
          title="Tốc độ"
        >
          {speeds[speedIdx]}x
        </button>
        <button
          onClick={(e) => {
            e.stopPropagation();
            onOpenAR?.();
          }}
          className="px-2.5 h-8 rounded-lg bg-[#805528] text-white text-xs font-semibold flex items-center gap-1 shadow-sm transition-transform active:scale-95"
          title="Ướm thử trong phòng với AR"
        >
          <span className="material-symbols-outlined text-[15px]">view_in_ar</span>
          <span>AR</span>
        </button>
      </div>
    </div>
  );
};
