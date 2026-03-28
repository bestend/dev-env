# AGENTS.md

이 저장소는 `bestend/dev-env` Docker 개발 환경을 관리합니다.

## 목적
- 개발용 올인원 Docker 이미지를 유지한다.
- Dockerfile, devcontainer, compose, shell/tmux 설정, release workflow를 함께 관리한다.

## 작업 원칙
- 새 의존성 추가는 꼭 필요한 경우만.
- 이미지 크기 증가와 빌드 시간 증가를 항상 고려한다.
- shell UX(zsh/p10k/fzf/tmux) 변경 시 실제 런타임 영향까지 확인한다.
- SSH / code-server / release workflow 변경 시 빌드와 런타임 검증을 같이 한다.

## 필수 검증
변경 범위에 맞게 아래를 실행한다.

### 기본
```bash
./tests/test-dev-image-layout.sh
bash -n scripts/*.sh tests/*.sh
python3 -m json.tool .devcontainer/devcontainer.json >/dev/null
```

### Docker/런타임 관련 변경 시
```bash
docker build -t bestend/dev-env:test .
./tests/test-dev-image-runtime.sh bestend/dev-env:test
./tests/test-dev-image-services.sh bestend/dev-env:test
```

## 릴리스 규칙
- Docker Hub 이미지 이름은 `docker.io/bestend/dev-env` 를 유지한다.
- `main` push workflow 태그 형식은 `YYYYMMDDHH-<shortsha>` + `latest` 를 유지한다.
- 태그 형식, 이미지 이름, workflow secrets 이름을 바꾸면 README도 같이 수정한다.

## 주의
- 인증 정보는 이미지에 bake 하지 않는다.
- `code-server` 확장 가용성은 레지스트리 차이(OpenVSX 등)로 달라질 수 있다.
- powerlevel10k 아이콘은 클라이언트 폰트 환경 영향이 있다.
